class Channel < ActiveRecord::Base
  attr_accessible :name, :url_name, :channel_percentage, :teacher_percentage, :email

  validates :name, :presence => true
  validates :url_name, :presence => true
  validates :channel_percentage, :presence => true, :allow_blank => false, :numericality => { :less_than_or_equal_to => 1, :message => "Channel percentage of revenue must be less than or equal to 1"}
  validates :teacher_percentage, :presence => true, :allow_blank => false, :numericality => { :less_than_or_equal_to => 1, :message => "Teacher percentage of revenue must be less than or equal to 1"}
  validate :percentage_sum_validation
  validates :email, allow_blank: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }

  has_many :channel_admins
  has_many :admin_users, :through => :channel_admins
  has_many :channel_chalklers
  has_many :chalklers, :through => :channel_chalklers
  has_many :channel_lessons
  has_many :lessons, :through => :channel_lessons
  has_many :bookings, :through => :lessons
  has_many :payments, :through => :bookings
  has_many :channel_categories
  has_many :categories, :through => :channel_categories

  #absolute minimum percentage of revenue paid to chalkle
  CHALKLE_PERCENTAGE = 0.125

  def percentage_sum_validation
    return unless channel_percentage and teacher_percentage
    if ( channel_percentage + teacher_percentage > 1 - CHALKLE_PERCENTAGE )
      errors.add(:channel_percentage, "Sum of revenue percentages must be less than chalkle percentage") 
      errors.add(:teacher_percentage, "Sum of revenue percentages must be less than chalkle percentage") 
    end
  end

  def chalkle_percentage
    1 - teacher_percentage - channel_percentage
  end

  def self.select_options(channel)
    channel.map { |c| [c.name, c.id] }
  end

  # channel chalkler performance calculation methods
  def self.new_chalklers(start_days_ago, end_days_ago, channel_id)
    Channel.find(channel_id).chalklers.where("created_at > current_date - #{start_days_ago} and created_at <= current_date - #{end_days_ago}").count
  end

  def self.active_chalklers(end_days_ago, channel_id)
    Channel.find(channel_id).chalklers.joins("LEFT OUTER JOIN bookings ON bookings.chalkler_id=chalklers.id").where("bookings.created_at > current_date - #{end_days_ago} - INTERVAL '3 MONTHS' OR chalklers.created_at > current_date - #{end_days_ago} - INTERVAL '3 MONTHS'").select("DISTINCT(chalklers.id)").count
  end

  def self.percent_active(end_days_ago, channel_id)
    if Channel.find(channel_id).chalklers.empty?
      return 0
    else
      return (100.0*Channel.active_chalklers(end_days_ago,channel_id) / Channel.find(channel_id).chalklers.count)
    end
  end

  # channel class performance calculation methods
  def self.total_revenue(start_days_ago,end_days_ago,channel_id)
    l = Channel.lesson_ran(start_days_ago,end_days_ago,channel_id)
    total = 0
    l.each do |lesson|
      total = lesson.collected_revenue + total
    end
    return total
  end

  def self.total_cost(start_days_ago,end_days_ago,channel_id)
    l = Channel.lesson_ran(start_days_ago,end_days_ago,channel_id)
    total = 0
    l.each do |lesson|
      if lesson.teacher_payment.present?
        total = total + lesson.teacher_payment + (lesson.venue_cost.present? ? lesson.venue_cost : 0) + (lesson.material_cost.present? ? lesson.material_cost : 0)
      else
        total = total + lesson.attendance*(lesson.teacher_cost.present? ? lesson.teacher_cost : 0)
      end
    end
    return total
  end

  def self.new_repeat_class(lessons_new,lessons_past)
    new_lesson = 0
    lessons_new.each do |lesson|
      if lessons_past.find_by_name(lesson.name).nil?
        new_lesson = new_lesson + 1
      end
    end
    return [new_lesson, lessons_new.length - new_lesson]
  end

  def self.classes_run(start_days_ago,end_days_ago,channel_id)
    Channel.new_repeat_class(Channel.lesson_ran(start_days_ago,end_days_ago,channel_id),Channel.past_classes(start_days_ago,channel_id))
  end

  def self.classes_cancel(start_days_ago,end_days_ago,channel_id)
    Channel.new_repeat_class(Channel.cancel_classes(start_days_ago,end_days_ago,channel_id),Channel.past_classes(start_days_ago,channel_id))
  end

  def self.classes_pay(start_days_ago,end_days_ago,channel_id)
    l = Channel.lesson_ran(start_days_ago,end_days_ago,channel_id)
    free = 0
    l.each do |lesson|
      if lesson.cost == 0 || lesson.cost.nil?
        free = free + 1
      end
    end
    return [l.length - free, free]
  end

  def self.attendee(start_days_ago,end_days_ago,channel_id)
    l = Channel.lesson_ran(start_days_ago,end_days_ago,channel_id)
    total = 0
    l.each do |lesson|
      total = total + lesson.attendance
    end
    return total
  end

  def self.seats(start_days_ago,end_days_ago,channel_id)
    l = Channel.lesson_ran(start_days_ago,end_days_ago,channel_id)
    total = 0
    l.each do |lesson|
      if lesson.attendance > 0
        total = total + (lesson.max_attendee.present? ? lesson.max_attendee : lesson.attendance)
      end
    end
    return total
  end

  def self.fill_fraction(start_days_ago,end_days_ago,channel_id)
    l = Channel.lesson_ran(start_days_ago,end_days_ago,channel_id)
    total = 0
    l.each do |lesson|
      if lesson.attendance > 0
        total = total + lesson.attendance.to_d / (lesson.max_attendee.present? ? lesson.max_attendee.to_d : lesson.attendance.to_d)
      end
    end
    if l.length > 0
      return total / l.length*100
    else
      return 0
    end
  end

  private

  def self.lesson_ran(start_days_ago,end_days_ago,channel_id)
    Channel.find(channel_id).lessons.visible.published.where("start_at > current_date - #{start_days_ago} and start_at <= current_date - #{end_days_ago}")
  end

  def self.cancel_classes(start_days_ago,end_days_ago,channel_id)
    Channel.find(channel_id).lessons.hidden.published.where("start_at > current_date - #{start_days_ago} and start_at <= current_date - #{end_days_ago}")
  end

  def self.past_classes(start_days_ago,channel_id)
    Channel.find(channel_id).lessons.visible.published.where("start_at < current_date - #{start_days_ago}")
  end


end
