require 'carrierwave'
require 'lesson_upload_image_uploader'

class Lesson < ActiveRecord::Base
  include Categorizable

  attr_accessible :name, :teacher_id, :status, :cost, :fee,
    :duration,:lesson_type, :teacher_bio, :do_during_class, :learning_outcomes,
    :max_attendee, :min_attendee, :availabilities, :prerequisites,
    :additional_comments, :donation, :lesson_skill, :venue, :category_id, :category,
    :channel_ids, :suggested_audience, :teacher_cost
  attr_accessible :name, :meetup_id, :meetup_url, :teacher_id, :status, :cost,
    :teacher_cost, :venue_cost, :start_at, :duration, :meetup_data,
    :description, :visible, :teacher_payment, :lesson_type, :teacher_bio,
    :do_during_class, :learning_outcomes, :max_attendee, :min_attendee,
    :availabilities, :prerequisites, :additional_comments, :donation,
    :lesson_skill, :venue, :published_at, :category_id, :category, :channel_ids,
    :lesson_image_attributes, :channel_percentage_override,
    :chalkle_percentage_override, :material_cost, :suggested_audience,
    :chalkle_payment, :attendance_last_sent_at, :lesson_upload_image,
    :remove_lesson_upload_image, :cached_channel_fee, :cached_chalkle_fee, :as => :admin

  has_many   :channel_lessons
  has_many   :channels, :through => :channel_lessons
  has_many   :bookings
  has_many   :chalklers, :through => :bookings
  has_many   :payments, :through => :bookings
  has_one    :lesson_image, :dependent => :destroy, :inverse_of => :lesson
  belongs_to :teacher, class_name: "Chalkler"
  belongs_to :category
  mount_uploader :lesson_upload_image, LessonUploadImageUploader

  accepts_nested_attributes_for :lesson_image

  delegate :name, :to => :teacher, :prefix => true, :allow_nil => true
  delegate :best_colour_num, to: :category, allow_nil: true

  #Time span for classes requiring attention
  PAST = 3
  IMMEDIATE_FUTURE= 5
  WEEK = 7

  #Lesson statuses
  STATUS_5 = "Processing"
  STATUS_4 = "Approved"
  STATUS_3 = "Unreviewed"
  STATUS_2 = "On-hold"
  STATUS_1 = "Published"
  VALID_STATUSES = [STATUS_1, STATUS_2, STATUS_3, STATUS_4, STATUS_5]

  #GST for NZ
  GST = 0.15

  validates_uniqueness_of :meetup_id, allow_nil: true
  validates_presence_of :name
  validates_numericality_of :teacher_payment, allow_nil: true
  validates_numericality_of :material_cost, allow_nil: false
  validates :status, :inclusion => { :in => VALID_STATUSES, :message => "%{value} is not a valid status"}
  validates :teacher_cost, :allow_blank => true, :numericality => {:greater_than_or_equal_to => 0, :message => "Teacher income per attendee must be positive" }
  validates :cost, :allow_blank => true, :numericality => {:greater_than_or_equal_to => 0, :message => "Advertised price must be positive" }
  validates :channel_percentage_override, allow_nil: true, :numericality => {:less_than_or_equal_to => 1, :message => "Channel percentage can not be greater than 100%" }
  validates :chalkle_percentage_override, allow_nil: true, :numericality => {:less_than_or_equal_to => 1, :message => "Chalkle percentage can not be greater than 100%" }
  validate :max_channel_percentage
  validate :max_teacher_cost
  validate :revenue_split_validation
  validate :min_teacher_percentage
  validate :image_size

  scope :hidden, where(visible: false)
  scope :visible, where(visible: true)
  scope :recent, where("start_at > current_date - #{PAST} AND start_at < current_date + #{IMMEDIATE_FUTURE}")
  scope :last_week, where("start_at > current_date - #{WEEK} AND start_at < current_date")
  scope :unreviewed, where(status: STATUS_3)
  scope :on_hold, where(status: STATUS_2)
  scope :approved, where(status: STATUS_4)
  scope :processing, where(status: STATUS_5)
  scope :unpublished, where{ status != STATUS_1 }
  scope :published, where(status: STATUS_1)
  scope :paid, where("cost > 0")
  scope :by_date, order(:start_at)
  scope :in_month, lambda {|month| where("start_at" => month.time_range)}
  #scope :in_month, lambda {|month| where(["\"lessons\".start_at ?", month.date_range.to_s(:db)]) }
  scope :in_week, lambda {|week| in_month(week)}
  scope :with_region, where("lessons.id IN (SELECT id FROM channel_lessons)")
  scope :displayable, lambda { published.visible }
  scope :upcoming_or_today, lambda { where("start_at >= ?", Time.now.to_date.to_time) }
  scope :not_meetup, where("meetup_url IS NULL")

  # CRAIG: This is a bit of a hack. Replace this system with a state machine.
  before_save :update_published_at

  def self.upcoming(limit = nil)
    return where{(visible == true) & (status == STATUS_1) & (start_at > Time.now.utc)} if limit.nil?
    where{(visible == true) & (status == STATUS_1) & (start_at > Time.now.utc) & (start_at < limit)}
  end

  # kaminari
  paginates_per 10

    #allow for mismatch due to rounding
  def revenue_split_validation
    return unless (channel_percentage_override.present? || chalkle_percentage_override.present?) and teacher_cost.present? and cost.present?
    if ( (rounding > 1) || (rounding < 0))
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

  def min_teacher_percentage
    return unless (channel_percentage_override? || chalkle_percentage_override?) and teacher_cost.present?
    errors.add(:channel_percentage_override, "Percentage of revenue allocated to teacher cannot be 0") unless ((1 - channel_percentage - chalkle_percentage > 0) || (teacher_cost == 0))
    errors.add(:chalkle_percentage_override, "Percentage of revenue allocated to teacher cannot be 0") unless ((1 - channel_percentage - chalkle_percentage > 0) || (teacher_cost == 0))
  end

  def image_size
    return unless lesson_upload_image.present?
    if lesson_upload_image.file.size.to_f/(1000*1000) > 4.to_f
      errors.add(:lesson_upload_image, "You cannot upload an image greater than 4 MB")
    end
  end

  delegate :channel_fee, :rounding, :chalkle_fee, :default_chalkle_percentage, :chalkle_percentage,
           :default_channel_percentage, :channel_percentage, :teacher_percentage, to: :cost_calculator

  def cost_calculator
    @cost_calculator ||= Finance::ClassCostCalculators::PercentageCommission.new(self)
  end

  #Class incomes
  def expected_turnover
    total = 0
    bookings.confirmed.visible.each do |b|
      total = total + (b.cost.present? ? b.cost : 0)
    end
    return total
  end

  def collected_turnover
    payments.sum(:total)
  end

  def cash_payment
    payments.cash.sum(:total)
  end

  def uncollected_turnover
    expected_turnover - collected_turnover
  end

  def total_cost
    if teacher_payment.present? && chalkle_payment.present?
      teacher_payment + cash_payment + ( venue_cost.present? ? venue_cost : 0 ) + ( material_cost.present? ? material_cost : 0 ) + chalkle_payment
    else
      attendance*( (teacher_cost.present? ? teacher_cost : 0) + chalkle_fee)
    end
  end

  def income
    excl_gst(collected_turnover - total_cost)
  end

  def image
    lesson_image.image rescue nil
  end

  # this should be a scope
  def bookable?
    spaces_left?
  end

  def spaces_left?
    !limited_spaces? || spaces_left > 0
  end

  def spaces_left
    [(max_attendee.to_i - attendance), 0].max
  end

  def limited_spaces?
    !!max_attendee
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
    class_not_done && start_at.present? && ( (start_at.present? ? start_at.to_datetime : Date.today()) - Date.today() < 7)
  end

  def complete_details?
    teacher_id.present? && start_at.present? && channels.any? && do_during_class.present? && teacher_cost.present? && venue_cost.present? && venue.present?
  end

  def class_may_cancel
    class_coming_up && ( attendance < (min_attendee.present? ? min_attendee : 2) )
  end

  def flag_warning
    if class_may_cancel
      return "May cancel"
    elsif !complete_details?
      return "Missing details"
    else
      return false
    end
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

  def set_name(name)
    return name.strip unless name.include?(':')
    parts = name.split(':')
    parts[1].strip
  end

  def copy_lesson
    except = %w{id created_at updated_at meetup_id meetup_url status start_at meetup_data description teacher_payment published_at chalkle_payment visible}
    copy_attributes = self.attributes.reject { |attr| except.include?(attr) }
    new_lesson = Lesson.new(copy_attributes, :as => :admin)
    new_lesson.channels = self.channels
    new_lesson.category = self.category
    new_lesson.visible = true
    new_lesson.save
    new_lesson
  end

  def free?
    cost == 0
  end

  def start_on
    start_at.to_date if start_at
  end
  alias_method :date, :start_on

  private

  #price calculation methods
  def excl_gst(price)
    price/(1 + GST)
  end

  def fee(teacher_price, teacher_percentage, channel_cut)
    return 0 unless teacher_percentage > 0
    teacher_price / teacher_percentage * channel_cut * (1 + GST)
  end

  def update_published_at
    self.published_at ||= Time.now
  end

end
