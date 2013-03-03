class Lesson < ActiveRecord::Base
  attr_accessible :name, :meetup_id, :category_id, :teacher_id, :status, :cost,
    :teacher_cost, :venue_cost, :start_at, :duration, :meetup_data,
    :description, :visible, :teacher_payment, :lesson_type, :teacher_bio,
    :do_during_class, :learning_outcomes, :max_attendee, :min_attendee,
    :availabilities, :prerequisites, :additional_comments, :donation,
    :lesson_skill, :venue, :published_at, :category_ids,
    :lesson_image_attributes, :channel_percentage_override, :chalkle_percentage_override

  has_many :channel_lessons
  has_many :channels, :through => :channel_lessons
  has_many :lesson_categories
  has_many :categories, :through => :lesson_categories
  has_many :bookings
  has_many :chalklers, :through => :bookings
  has_many :payments, :through => :bookings
  belongs_to :teacher, class_name: "Chalkler"
  has_one :lesson_image, :dependent => :destroy, :inverse_of => :lesson

  accepts_nested_attributes_for :lesson_image

  #Time span for classes requiring attention
  PAST = 3
  IMMEDIATE_FUTURE= 5
  WEEK = 7

  #Lesson statuses
  STATUS_4 = "Approved"
  STATUS_3 = "Unreviewed"
  STATUS_2 = "On-hold"
  STATUS_1 = "Published"
  VALID_STATUSES = [STATUS_1, STATUS_2, STATUS_3, STATUS_4]

  validates_uniqueness_of :meetup_id, allow_nil: true
  validates_presence_of :name
  validates_numericality_of :teacher_payment, allow_nil: true
  validates :status, :inclusion => { :in => VALID_STATUSES, :message => "%{value} is not a valid status"}
  validates :teacher_cost, :allow_blank => true, :numericality => {:greater_than_or_equal_to => 0, :message => "Teacher income per attendee must be positive" }
  validates :cost, :allow_blank => true, :numericality => {:greater_than_or_equal_to => 0, :message => "Advertised price must be positive" }
  validates :channel_percentage_override, allow_nil: true, :numericality => {:less_than_or_equal_to => 1, :message => "Channel percentage can not be greater than 100%" }
  validates :chalkle_percentage_override, allow_nil: true, :numericality => {:less_than_or_equal_to => 1, :message => "Chalkle percentage can not be greater than 100%" }
  validate :max_channel_percentage
  validate :max_teacher_cost
  validate :revenue_split_validation

  scope :hidden, where(visible: false)
  scope :visible, where(visible: true)
  scope :recent, where("start_at > current_date - " + PAST.to_s + " AND start_at < current_date + " + IMMEDIATE_FUTURE.to_s)
  scope :upcoming, where("start_at >= current_date AND start_at < current_date + " + WEEK.to_s)
  scope :last_week, where("start_at > current_date - " + WEEK.to_s + " AND start_at < current_date ")
  scope :unpublished, where("(status = '" + STATUS_3 + "' ) OR (status = '" + STATUS_2 + "' )")
  scope :published, where("status = '" + STATUS_1 + "'")

  before_create :set_from_meetup_data
  before_create :set_metadata

  #allow for mismatch due to rounding
  def revenue_split_validation
    return unless (channel_percentage_override.present? || chalkle_percentage_override.present?) and teacher_cost.present? and cost.present?
    if ( ((channel_percentage*cost + chalkle_percentage*cost + teacher_cost - cost) > 0.05) || ((channel_percentage*cost + chalkle_percentage*cost + teacher_cost - cost) < -0.5))
      errors.add(:channel_percentage_override, "Advertised price must be split between teacher, channel and chalkle") 
      errors.add(:chalkle_percentage_override, "Advertised price must be split between teacher, channel and chalkle") 
      errors.add(:teacher_cost, "Advertised price must be split between teacher, channel and chalkle") 
    end
  end

  def max_channel_percentage
    return unless channel_percentage_override.present? and chalkle_percentage
    errors.add(:channel_percentage_override, "Percentage of revenue paid to channel is too high") unless (channel_percentage <= 1 - chalkle_percentage)
  end

  def max_teacher_cost
    return unless teacher_cost and cost
    if (teacher_cost > cost)
      errors.add(:teacher_cost, "Payment to teacher must be less than advertised price")
      errors.add(:cost, "Payment to teacher must be less than advertised price") 
    end 
  end

  def default_chalkle_percentage
    if channels.present?
      return channels.collect{|c| c.chalkle_percentage}.first
    else
      return 0.125
    end
  end

  def chalkle_percentage
    return chalkle_percentage_override unless chalkle_percentage_override.nil?
    default_chalkle_percentage
  end

  def default_channel_percentage
    if channels.present?
      return channels.collect{|c| c.channel_percentage}.first
    else
      return 0.125
    end
  end

  def channel_percentage
    return channel_percentage_override unless channel_percentage_override.nil?
    default_channel_percentage
  end

  def gst_price
    cost.present? ? (cost*1.15).round(1) : nil
  end

  def image
    lesson_image.image rescue nil
  end

  def published?
    status == STATUS_1
  end

  def valid_statuses
    VALID_STATUSES
  end

  def unpaid_count
    bookings.confirmed.visible.count - bookings.confirmed.visible.paid.count
  end

  def class_not_done
    ((start_at.present? ? start_at.to_datetime : Date.today()) - Date.today() > -1)
  end

  def class_coming_up
    class_not_done && start_at.present? && ( (start_at.present? ? start_at.to_datetime : Date.today()) - Date.today() < 4)
  end

  def class_may_cancel
    class_coming_up && ( attendance < (min_attendee.present? ? min_attendee : 2) )
  end

  def expected_revenue
    total = 0
    bookings.confirmed.visible.each do |b|
      total = total + (b.cost.present? ? b.cost : 0)
    end
    return total
  end

  def collected_revenue
    payments.sum(:total)/1.15
  end

  def uncollected_revenue
    expected_revenue - collected_revenue
  end

  def income
    collected_revenue - ( teacher_payment.present? ? teacher_payment : 0 ) - ( venue_cost.present? ? venue_cost : 0 )
  end

  def attendance
    bookings.confirmed.visible.sum(:guests) + bookings.confirmed.visible.count
  end

  def pay_involved
    (cost.present? ? cost : 0) > 0
  end

  def todo_attendee_list
    return (start_at > DateTime.now()) && (start_at <= DateTime.tomorrow() + 1) && pay_involved
  end

  def todo_pay_reminder
    return unpaid_count > 0 && pay_involved && ( start_at < DateTime.now() + 4 )
  end

  def todo_payment_summary
    return pay_involved && ( (teacher_cost.present? ? teacher_cost : 0) > 0 ) && ( start_at < DateTime.now() ) && ( start_at > DateTime.now() - 2)
  end

  def meetup_data
    data = read_attribute(:meetup_data)
    if data.present?
      event = JSON.parse(data)
      event["event"]
    else
      {}
    end
  end

  def self.create_from_meetup_hash(result, channel)
    l = Lesson.find_or_initialize_by_meetup_id result.id
    l.status = STATUS_1
    l.name = l.set_name result.name
    l.meetup_id = result.id
    l.description = result.description
    l.meetup_data = result.to_json
    l.save
    l.set_category result.name
    l.channels << channel unless l.channels.exists? channel
    l.valid?
  end

  def set_category(name)
    return unless name.include?(':')
    parts = name.split(':')
    c = Category.find_by_name parts[0]
    categories << c unless (c.nil? || categories.exists?(c))
  end

  def set_name(name)
    return name.strip unless name.include?(':')
    parts = name.split(':')
    parts[1].strip
  end

  private

  def set_from_meetup_data
    return if meetup_data.empty?
    self.created_at = Time.at(meetup_data["created"] / 1000)
    self.published_at = Time.at(meetup_data["created"] / 1000)
    self.updated_at = Time.at(meetup_data["updated"] / 1000)
    self.start_at = Time.at(meetup_data["time"] / 1000) if meetup_data["time"]
    self.duration = meetup_data["duration"] / 1000 if meetup_data["duration"]
  end

  def set_metadata
    self.visible = true
  end

end
