require 'carrierwave/orm/activerecord'
require 'course_upload_image_uploader'

class Course < ActiveRecord::Base
  include Categorizable
  include Gst

  attr_accessible *BASIC_ATTR = [
    :name, :lessons, :bookings, :status, :visible, :course_type, :teacher_id, :cost, :fee, :teacher_bio, :do_during_class, :learning_outcomes, :max_attendee, :min_attendee, :availabilities, :prerequisites, :additional_comments, :donation, :course_skill, :venue, :category_id, :category, :channel_id, :suggested_audience, :teacher_cost, :region_id, :channel_rate_override
  ]

  attr_accessible  *BASIC_ATTR, :meetup_id, :meetup_url, :venue_cost, :meetup_data, :description, :teacher_payment, :published_at, :category_id, :category, :course_image_attributes, :material_cost, :chalkle_payment, :attendance_last_sent_at, :course_upload_image, :remove_course_upload_image, :cached_channel_fee, :cached_chalkle_fee, :as => :admin

  #Course statuses
  STATUS_5 = "Processing"
  STATUS_4 = "Approved"
  STATUS_3 = "Unreviewed"
  STATUS_2 = "On-hold"
  STATUS_1 = "Published"
  VALID_STATUSES = [STATUS_1, STATUS_2, STATUS_3, STATUS_4, STATUS_5]

  belongs_to :region
  belongs_to :channel
  belongs_to :teacher, class_name: "Chalkler"
  belongs_to :category
  has_many  :lessons
  has_many  :bookings
  has_many  :chalklers, through: :bookings
  has_many  :payments, through: :bookings
  has_one   :course_image, :dependent => :destroy, :inverse_of => :course
  has_many  :bookings
  has_many  :chalklers, through: :bookings
  has_many  :payments, through: :bookings

  mount_uploader :course_upload_image, CourseUploadImageUploader

  accepts_nested_attributes_for :course_image

  [:teacher, :channel, :region, :category].each {|resource| delegate :name, :to => resource, :prefix => true, :allow_nil => true}

  delegate :best_colour_num, to: :category, allow_nil: true
  
  #Time span for classes requiring attention
  PAST = 3
  IMMEDIATE_FUTURE= 5
  WEEK = 7

  GST = gst_rate_for :nz #GST for NZ
  
  validates_uniqueness_of :meetup_id, allow_nil: true
  validates_presence_of :name
  validates_presence_of :lessons
  validates_numericality_of :teacher_payment, allow_nil: true
  validates_numericality_of :material_cost, allow_nil: false
  validates :status, :inclusion => { :in => VALID_STATUSES, :message => "%{value} is not a valid status"}
  validates :teacher_cost, :allow_blank => true, :numericality => {:greater_than_or_equal_to => 0, :message => "Teacher income per attendee must be positive" }
  validates :cost, :allow_blank => true, :numericality => {:greater_than_or_equal_to => 0, :message => "Advertised price must be positive" }
  validates :lessons, :length => { minimum: 1 }
  validate :max_teacher_cost
  validate :image_size

  scope :start_at_between, lambda {|from,to| joins(:lessons).where("lessons.start_at BETWEEN ? AND ?", from.to_s(:db), to.to_s(:db))}
  scope :hidden, where(visible: false)
  scope :visible, where(visible: true)
  scope :recent, visible.joins(:lessons).where("start_at > current_date - #{PAST} AND start_at < current_date + #{IMMEDIATE_FUTURE}")
  scope :last_week, joins(:lessons).visible.where("start_at > current_date - #{WEEK} AND start_at < current_date")
  scope :unreviewed, visible.where(status: STATUS_3)
  scope :on_hold, visible.where(status: STATUS_2)
  scope :approved, visible.where(status: STATUS_4)
  scope :processing, where(status: STATUS_5)
  scope :unpublished, visible.where{ status != STATUS_1 }
  scope :published, visible.where(status: STATUS_1)
  scope :paid, where("cost > 0")
  scope :by_date, joins(:lessons).order('lessons.start_at')
  scope :in_month, lambda {|month| joins(:lessons).where("lessons.start_at BETWEEN ? AND ?", month.first_day.to_s(:db), month.last_day.to_s(:db))}
  scope :in_week, lambda {|week| in_month(week)}
  scope :displayable, lambda { published.visible }
  scope :upcoming_or_today, lambda { joins(:lessons).where("start_at >= ?", Time.now.to_date.to_time) }
  scope :not_meetup, where("meetup_url IS NULL")
  scope :only_with_region, lambda {|region| where(region_id: region.id) }
  scope :only_with_channel, lambda {|channel| where(channel_id: channel.id) }
  scope :with_base_category, lambda {|category| includes(:category).where("categories.id = :cat_id OR categories.parent_id = :cat_id", {cat_id: category.id}) }

  # CRAIG: This is a bit of a hack. Replace this system with a state machine.
  before_save :update_published_at

  def self.upcoming(limit = nil)
    return published.joins(:lessons).where("start_at > ?", Time.now.utc) if limit.nil?
    published.joins(:lessons).where("start_at > ?", Time.now.utc).where("start_at < ?", limit)
  end

  def first_lesson
    lessons.order('start_at desc').limit(1).first
  end

  def start_at
    first_lesson.try :start_at if first_lesson
  end

  def start_at=(lesson_start)
    first_lesson.start_at=lesson_start
    first_lesson.save
  end

  def duration
    lessons.inject(0){|sum, l| l.duration ? sum += l.duration : sum }
  end

  def duration=(first_lesson_duration)
    first_lesson.duration=first_lesson_duration
    first_lesson.save
  end


  # kaminari
  paginates_per 10

  def max_teacher_cost
    return unless teacher_cost and cost
    if (teacher_cost > cost)
      errors.add(:teacher_cost, "Payment to teacher must be less than advertised price")
      errors.add(:cost, "Payment to teacher must be less than advertised price")
    end
  end

  def image_size
    return unless course_upload_image.present?
    if course_upload_image.file.size.to_f/(1000*1000) > 4.to_f
      errors.add(:course_upload_image, "You cannot upload an image greater than 4 MB")
    end
  end

  delegate :channel_fee, :rounding, :chalkle_fee, :chalkle_percentage,
           :channel_percentage, :teacher_percentage, to: :cost_calculator

  def cost_calculator
    result = channel ? channel.cost_calculator : CostModel.default.cost_calculator
    result.course = self
    result
  end

  def update_costs
    cost_calculator.update_costs(self)
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
    course_image.image rescue nil
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
    teacher_id.present? && start_at.present? && channel && do_during_class.present? && teacher_cost.present? && venue_cost.present? && venue.present?
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

  def copy_course
    except = %w{id created_at updated_at meetup_id meetup_url status start_at meetup_data description teacher_payment published_at chalkle_payment visible}
    copy_attributes = self.attributes.reject { |attr| except.include?(attr) || attr.starts_with?('deprecated_') }
    new_course = Course.new(copy_attributes, :as => :admin)
    new_course.category = self.category
    new_course.visible = true
    new_course.save
    new_course
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
