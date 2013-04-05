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

  #Channel performances
  def financial_stats(start, period)    
    Financial_stats.new(start,period,self)
  end

  def chalkler_stats(start, period)
    Chalkler_stats.new(start,period,self)
  end

  def classes_run(start_days_ago,end_days_ago)
    new_repeat_class(lesson_ran(start_days_ago,end_days_ago),past_classes(start_days_ago))
  end

  def classes_cancel(start_days_ago,end_days_ago)
    new_repeat_class(cancel_classes(start_days_ago,end_days_ago),past_classes(start_days_ago))
  end

  def classes_pay(start_days_ago,end_days_ago)
    l = lesson_ran(start_days_ago,end_days_ago)
    free = 0
    l.each do |lesson|
      if lesson.cost == 0 || lesson.cost.nil?
        free = free + 1
      end
    end
    return l.length - free
  end


  def fill_fraction(start_days_ago,end_days_ago)
    l = lesson_ran(start_days_ago,end_days_ago)
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

  def performance_lessons(last_day, num_weeks)
    lessons = []
    lessons[0] = classes_run((Date.today() - last_day.weeks_ago(1)).to_i,(Date.today() - last_day).to_i)
    lessons_change = []
    pay_lessons = []
    pay_lessons[0] = classes_pay((Date.today() - last_day.weeks_ago(1)).to_i,(Date.today() - last_day).to_i)
    pay_lessons_change =[]
    cancellations = []
    cancellations[0] = classes_cancel((Date.today() - last_day.weeks_ago(1)).to_i,(Date.today() - last_day).to_i)
    cancellations_change = []
    (1..num_weeks).each do |i|
      lessons[i] = classes_run((Date.today() - last_day.weeks_ago(i+1)).to_i,(Date.today() - last_day.weeks_ago(i)).to_i)         
      lessons_change[i-1] = (lessons[i].sum() > 0) ? (lessons[i-1].sum().to_d/lessons[i].sum() - 1.0)*100.0 : nil
      pay_lessons[i] = classes_pay((Date.today() - last_day.weeks_ago(i+1)).to_i,(Date.today() - last_day.weeks_ago(i)).to_i)
      pay_lessons_change[i-1] = (pay_lessons[i] > 0) ? (pay_lessons[i-1].to_d/pay_lessons[i] - 1.0)*100.0 : nil
      cancellations[i] = classes_cancel((Date.today() - last_day.weeks_ago(i+1)).to_i,(Date.today() - last_day.weeks_ago(i)).to_i)
      cancellations_change[i-1] = (cancellations[i].sum() > 0) ? (cancellations[i-1].sum().to_d/cancellations[i].sum() - 1.0)*100.0 : nil
    end
    lessons.pop
    pay_lessons.pop
    cancellations.pop
    return [lessons, lessons_change, pay_lessons, pay_lessons_change, cancellations, cancellations_change]
  end

  def new_chalklers(start_date,end_date)
    chalklers.where{(created_at.gt start_date.utc) & (created_at.lteq end_date.utc)}
  end

  def all_chalklers(date)
    chalklers.where{created_at.lteq date.utc}
  end

  def lesson_ran2(start_date,end_date)
    lessons.visible.published.where{(start_at.gt start_date.utc) & (start_at.lteq end_date.utc)}
  end

  def lesson_ran(start_days_ago,end_days_ago)
    start_date = (Date.today() - start_days_ago.days).to_s
    end_date = (Date.today() - end_days_ago.days).to_s
    lessons.visible.published.where{(start_at.gt start_date) & (start_at.lteq end_date)}
  end

  def cancel_classes(start_days_ago,end_days_ago)
    start_date = (Date.today() - start_days_ago.days).to_s
    end_date = (Date.today() - end_days_ago.days).to_s
    lessons.hidden.published.where{(start_at.gt start_date) & (start_at.lteq end_date)}
  end

  def past_classes(start_days_ago)
    start_date = (Date.today() - start_days_ago.days).to_s
    lessons.visible.published.where{start_at.lt start_date}
    lessons.visible.published.where("start_at < current_date - #{start_days_ago}")
  end

  def new_repeat_class(lessons_new,lessons_past)
  new_lesson = 0
    lessons_new.each do |lesson|
      if lessons_past.find_by_name(lesson.name).nil?
        new_lesson = new_lesson + 1
      end
    end
    return [new_lesson, lessons_new.length - new_lesson]
  end

end
