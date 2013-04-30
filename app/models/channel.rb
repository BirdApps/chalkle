class Channel < ActiveRecord::Base
  attr_accessible :name, :url_name, :channel_percentage, :teacher_percentage, :email, :as => :admin

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
  def channel_stats(start,period)
    ChannelStats.new(start,period,self)
  end

  def financial_table(first_day, period, num_rows)
    financials = StatsMath.new()
    num_rows.times do |i|
      financials[i] = channel_stats(first_day + i*period, period).financial_stats
    end
    financials
  end

  def lessons_table(first_day, period, num_rows)
    lessons = StatsMath.new()
    num_rows.times do |i|
      lessons[i] = channel_stats(first_day + i*period, period).lesson_stats
    end
    lessons
  end

  def chalkler_table(first_day, period, num_rows)
    chalkler = StatsMath.new()
    num_rows.times do |i|
      chalkler[i] = channel_stats(first_day + i*period, period).chalkler_stats
    end
    chalkler
  end

  #Properties of Channels
  def new_chalklers(start_date,end_date)
    chalklers.where{(created_at.gt start_date.utc) & (created_at.lteq end_date.utc)}
  end

  def all_chalklers(date)
    chalklers.where{created_at.lteq date.utc}
  end

  def lesson_announced(start_date,end_date)
    lessons.published.where{(start_at.gt start_date.utc) & (start_at.lteq end_date.utc)}
  end

  def lesson_ran(start_date,end_date)
    lessons.visible.published.where{(start_at.gt start_date.utc) & (start_at.lteq end_date.utc)}
  end

  def cancel_lessons(start_date,end_date)
    lessons.hidden.published.where{(start_at.gt start_date.utc) & (start_at.lteq end_date.utc)}
  end

  def past_lessons(date)
    lessons.visible.published.where{start_at.lt date.utc}
  end

  def paid_lessons(start_date,end_date)
    lesson_ran(start_date,end_date).paid
  end

end
