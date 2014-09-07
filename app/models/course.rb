require 'carrierwave/orm/activerecord'
require 'course_upload_image_uploader'

class Course < ActiveRecord::Base
  include Categorizable
  include Gst
  
  attr_accessible *BASIC_ATTR = [
    :name, :lessons, :bookings, :status, :visible, :course_type, :teacher_id, :cost, :fee, :do_during_class, :learning_outcomes, :max_attendee, :min_attendee, :availabilities, :prerequisites, :additional_comments, :donation, :course_skill, :venue, :category_id, :category, :channel, :channel_id, :suggested_audience, :teacher_cost, :region_id, :region, :channel_rate_override, :repeat_course, :repeat_course_id, :start_at, :lessons_attributes, :duration, :url_name, :street_number, :street_name, :city, :postal_code, :longitude, :latitude, :teacher, :course_upload_image, :venue_cost, :venue_address, :first_lesson_start_at
  ]

  attr_accessible  *BASIC_ATTR, :meetup_id, :meetup_url, :meetup_data, :description, :teacher_payment, :published_at, :course_image_attributes, :material_cost, :chalkle_payment, :attendance_last_sent_at, :course_upload_image, :remove_course_upload_image, :cached_channel_fee, :cached_chalkle_fee, :as => :admin

  #Course statuses
  STATUS_5 = "Processing"
  STATUS_4 = "Completed"
  STATUS_3 = "Unreviewed"
  STATUS_2 = "On-hold"
  STATUS_1 = "Published"
  VALID_STATUSES = [STATUS_1, STATUS_2, STATUS_3, STATUS_4, STATUS_5]

  belongs_to :repeat_course
  belongs_to :region
  belongs_to :channel
  belongs_to :teacher, class_name: "ChannelTeacher"
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
  accepts_nested_attributes_for :lessons

  [:teacher, :channel, :region, :category].each {|resource| delegate :name, :to => resource, :prefix => true, :allow_nil => true}

  delegate :best_colour_num, to: :category, allow_nil: true
  
  #Time span for classes requiring attention
  PAST = 3
  IMMEDIATE_FUTURE= 5
  WEEK = 7

  GST = gst_rate_for :nz #GST for NZ
  
  validates_uniqueness_of :meetup_id, allow_nil: true
  validates_presence_of :name
  validates_presence_of :lessons, if: :published?
  validates_presence_of :channel
  validates_numericality_of :teacher_payment, allow_nil: true
  validates_numericality_of :material_cost, allow_nil: false
  validates :status, :inclusion => { :in => VALID_STATUSES, :message => "%{value} is not a valid status"}
  validates :teacher_cost, :allow_blank => true, :numericality => {:greater_than_or_equal_to => 0, :message => "Teacher income per attendee must be positive" }
  validates :cost, :allow_blank => true, :numericality => {:greater_than_or_equal_to => 0, :message => "Advertised price must be positive" }
  validates :lessons, :length => { minimum: 1 }, if: :published?
  validate :max_teacher_cost
  validate :image_size


  scope :hidden, where(visible: false)
  scope :visible, where(visible: true)
  scope :displayable, lambda { published.visible }

  scope :start_at_between, lambda{ |from,to| where(:start_at => from.beginning_of_day..to.end_of_day) }
  scope :recent, visible.start_at_between(DateTime.now.advance(days: PAST), DateTime.now.advance(days: IMMEDIATE_FUTURE))
  scope :last_week, visible.start_at_between(DateTime.now.advance(weeks: -1), DateTime.now)
  scope :in_month, lambda{|month| start_at_between(month.first_day, month.last_day) }
  scope :in_week, lambda {|week| start_at_between(week.first_day, week.last_day) }
  scope :on_date, lambda {|date| start_at_between(date, date) }
  scope :in_future, lambda { where( "start_at >= ?", DateTime.now.beginning_of_day) }
  scope :previous, lambda { where("start_at < ?", DateTime.now.beginning_of_day) }
  #TODO: replace references to previous with in_past - time consuming because previous is common word
  scope :in_past, previous
  scope :by_date, order(:start_at)
  scope :by_date_desc, order('start_at DESC')

  scope :unreviewed, visible.where(status: STATUS_3)
  scope :on_hold, visible.where(status: STATUS_2)
  scope :approved, visible.where(status: STATUS_4)
  scope :processing, where(status: STATUS_5)
  scope :unpublished, visible.where{ status != STATUS_1 }
  scope :published, visible.where(status: STATUS_1)
  scope :paid, where("cost > 0")
  scope :not_meetup, where("meetup_url IS NULL")
  scope :in_region, lambda {|region| where(region_id: region.id) }
  scope :in_channel, lambda {|channel| where(channel_id: channel.id) }
  scope :in_category, lambda {|category| includes(:category).where("categories.id = :cat_id OR categories.parent_id = :cat_id", {cat_id: category.id}) }
  scope :not_repeat_course, where(repeat_course_id: nil)

  # CRAIG: This is a bit of a hack. Replace this system with a state machine.
  before_save :update_published_at

  before_save :save_first_lesson

  def self.upcoming(limit = nil)
    return published.joins(:lessons).where("start_at > ?", Time.now.utc) if limit.nil?
    published.joins(:lessons).where("start_at > ?", Time.now.utc).where("start_at < ?", limit)
  end

  def repeating_class?
    true if repeat_course.present?
  end

  def address
    venue_address
  end

  def course?
    true if lessons.count > 1
  end

  def single_class
    true if lessons.count == 1
  end

  def first_lesson
    lessons.order('start_at desc').limit(1).first
  end

  def first_or_new_lesson
    @first_or_new_lesson ||= ( first_lesson || Lesson.new(course_id: id) )
  end

  def first_lesson_start_at
    first_lesson.try :start_at if first_lesson
  end

  def new? 
    true if !repeat_course || repeat_course.courses.count == 1
    false
  end

  def first_lesson_start_at=(lesson_start)
    first_or_new_lesson.update_attribute :start_at, lesson_start
  end

  def learning_hours
    lessons.inject(0){|sum, l| l.duration ? sum += l.duration : sum }
  end

  def duration
    first_or_new_lesson.duration
  end

  def duration=(first_lesson_duration)
    first_or_new_lesson.duration = first_lesson_duration.to_d*60*60.to_i
  end

  def reference
    start_at.strftime("%y%m%d")+self.id.to_s
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
    begin
      if course_upload_image.file.size.to_f/(1000*1000) > 4.to_f
        errors.add(:course_upload_image, "You cannot upload an image greater than 4 MB")
      end
    rescue
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
    new_lesson = Lesson.create({start_at: start_at, duration: duration})
    new_course.lessons = [new_lesson]
    new_course.save
    new_course
  end

  def free?
    cost == 0
  end

  def path
    if channel.nil?
      self.channel = Course.find(self.id).channel
    end
    "/#{channel.url_name}/#{url_name}/#{id}"
  end

  def path_series
    "/#{channel.url_name}/#{url_name}"
  end

  def start_on
    start_at.to_date if start_at
  end
  alias_method :date, :start_on

  def end_at
    start_at+duration if start_at && duration
  end
  alias_method :end_on, :end_at

  def reviews
    []
  end

  def has_reviews
    true
  end

  def review_percent
    100
  end

  def venue_truncated
    return if !venue || venue.empty?
    truncated = venue.split()[0..venue[0..16].split(" ").count()-1].join(" ")
    truncated[truncated.length-1] = truncated[truncated.length-1].gsub(/[^0-9A-Za-z]/, '')
    truncated
  end

  private
  def class_or_course
    return 'class' if lessons.count < 2
    'course'
  end

  def save_first_lesson
    @first_or_new_lesson.save if @first_or_new_lesson
  end

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

  before_create :set_url_name
  before_save :check_url_name
  
  def set_url_name
    self.url_name = name.parameterize
  end

  def check_url_name
    self.url_name = name.parameterize if self.url_name.nil?
  end
  
end
