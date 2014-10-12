require 'carrierwave/orm/activerecord'
require 'course_upload_image_uploader'

class Course < ActiveRecord::Base
  include Categorizable
  GST = 0.15

  attr_accessible *BASIC_ATTR = [
    :name, :lessons, :bookings, :status, :visible, :course_type, :teacher_id, :fee, :do_during_class, :learning_outcomes, :max_attendee, :min_attendee, :availabilities, :prerequisites, :additional_comments, :course_skill, :venue, :category_id, :category, :channel, :channel_id, :suggested_audience,  :region_id, :region, :repeat_course, :repeat_course_id, :start_at, :lessons_attributes, :duration, :url_name, :street_number, :street_name, :city, :postal_code, :longitude, :latitude, :teacher, :course_upload_image, :venue_address, :first_lesson_start_at, :cost, :teacher_cost, :course_class_type, :processing_fee, :teacher_pay_type, :note_to_attendees, :cancelled_reason
  ]

  attr_accessible  *BASIC_ATTR, :description, :teacher_payment, :published_at, :course_image_attributes, :chalkle_payment, :attendance_last_sent_at, :course_upload_image, :remove_course_upload_image, :cached_channel_fee, :cached_chalkle_fee, :as => :admin

  #chalkle fee is cached without GST
  #channel fee is specified inc. GST so is cached including it


  #Course statuses
  STATUS_5 = "Processing"
  STATUS_4 = "Completed"
  STATUS_3 = "Unreviewed"
  STATUS_2 = "Cancelled"
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

  validates_presence_of :name
  validates_presence_of :lessons, if: :published?
  validates_presence_of :channel
  validates_presence_of :teacher 
  validates_numericality_of :teacher_payment, allow_nil: true
  validates :status, :inclusion => { :in => VALID_STATUSES, :message => "%{value} is not a valid status"}
  validates :teacher_cost, :allow_blank => true, :numericality => {:greater_than_or_equal_to => 0, :message => "Teacher fee must be positive" }
  validates :cost, :allow_blank => true, :numericality => {:greater_than_or_equal_to => 0, :message => "Class price must be positive" }
  validates :lessons, :length => { minimum: 1 }, if: :published?
  validate :image_size
  validate :check_start_at
  validate :check_url_name

  scope :hidden, where(visible: false)
  scope :visible, where(visible: true)
  scope :displayable, lambda { published.visible }

  scope :start_at_between, lambda{ |from,to| where(:start_at => from.beginning_of_day..to.end_of_day) }
  scope :recent, visible.start_at_between(DateTime.current.advance(days: PAST), DateTime.current.advance(days: IMMEDIATE_FUTURE))
  scope :last_week, visible.start_at_between(DateTime.current.advance(weeks: -1), DateTime.current)
  scope :in_month, lambda{|month| start_at_between(month.first_day, month.last_day) }
  scope :in_week, lambda {|week| start_at_between(week.first_day, week.last_day) }
  scope :in_fortnight, lambda {|week| start_at_between(week.first_day, (week+1).last_day) }
  
  scope :on_date, lambda {|date| start_at_between(date, date) }
  scope :in_future, lambda { where( "end_at >= ?", DateTime.current) }
  scope :previous, lambda { where("start_at < ?", DateTime.current) }
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
  scope :taught_by_chalkler, lambda {|chalkler| joins(:teacher).where('channel_teachers.chalkler_id = ?', chalkler.id) }
  scope :in_region, lambda {|region| where(region_id: region.id) }
  scope :in_channel, lambda {|channel| where(channel_id: channel.id) }
  scope :in_category, lambda {|category| includes(:category).where("categories.id = :cat_id OR categories.parent_id = :cat_id", {cat_id: category.id}) }
  scope :not_repeat_course, where(repeat_course_id: nil)
  scope :popular, start_at_between(DateTime.current, DateTime.current.advance(days: 20))
  scope :adminable_by, lambda {|chalkler| joins(:channel => :channel_admins).where('channel_admins.chalkler_id = ?', chalkler.id)}

  scope :need_outgoing_payments, paid.joins(:bookings).where("courses.status = '#{STATUS_4}' AND courses.end_at < '#{DateTime.current.advance(weeks:-2).to_formatted_s(:db)}' AND (bookings.teacher_payment_id IS NULL OR bookings.channel_payment_id IS NULL)")

  scope :needs_completing, where("status = '#{STATUS_1}' AND end_at < ?", DateTime.current)

  before_create :set_url_name
  before_save :update_published_at
  before_save :save_first_lesson
  after_save :start_at!
  after_save :end_at!
  after_save :expire_cache!

  def self.upcoming(limit=nil, options={:include_unpublished => false})
    unless options[:include_unpublished] 
      return published.in_future if limit.nil?
      published.in_future.where("start_at < ?", limit)
    else
      return in_future if limit.nil?
      in_future.where("start_at < ?", limit)
    end
  end

  def self.search(query, course_set = nil)
    if query.present?
      courses = Course.arel_table
      query_parts = query.split(/\W+/).map {|part| "%#{part}%" }
      if course_set
        course_set.where courses[:name].matches_any(query_parts)
      else
        Course.where courses[:name].matches_any(query_parts)
      end
    end
  end

  def cancel!(reason = nil)
    #TODO: notify chalklers
    self.status = STATUS_2
    self.cancelled_reason = reason if reason
    bookings.each do |booking|
      booking.cancel!(reason, true)
    end
    save
  end

  def complete!
    #TODO: run at midnight everynight on scope Course.needs_completing
    if end_at < DateTime.current
      if bookings.present?
        self.status = STATUS_4
      else
        self.status = STATUS_3
      end
      save
    end
  end

  def can_be_cancelled?
    (start_at > DateTime.current.advance(hours: 24) || !bookings? ) && status==STATUS_1 ? true : false
  end

  def classes
    lessons.order(:start_at)
  end

  def repeating_class?
    true if repeat_course.present?
  end

  def repeating?
    repeating_class?
  end

  def next_class
    repeat_course.courses[repeat_course.courses.index(repeat_course.courses.find(id))+1] if repeat_course.present?
  end

  def bookings?
    bookings.present?
  end

  def address
    venue_address
  end

  def address_formatted
    venue_address.gsub(',',',<br />').html_safe if venue_address.present?
  end

  def course?
    true if lessons.count > 1
  end

  def class?
    !course?
  end

  def single_class?
    true if lessons.count == 1
  end

  def first_lesson
    lessons.order('start_at').limit(1).first
  end
  def last_lesson
    lessons.order('start_at DESC').limit(1).last
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

  def hours
    (self.duration || 0)/3600 
  end

  def duration=(first_lesson_duration)
    first_or_new_lesson.duration = first_lesson_duration.to_d*60*60.to_i
  end

  def reference
    start_at.strftime("%y%m%d")+self.id.to_s
  end

  def publish!
    self.visible = true
    self.status = "Published"
    self.save
  end

  def publish
    self.visible = true
    self.status = "Published"
  end

  # kaminari
  paginates_per 10

  def image_size
    return unless course_upload_image.present?
    begin
      if course_upload_image.file.size.to_f/(1000*1000) > 4.to_f
        errors.add(:course_upload_image, "You cannot upload an image greater than 4 MB")
      end
    rescue
    end
  end

  #placeholder for when we go international
  def country_code
    :nz
  end


  ###
  # Costings
  ###

  def channel_plan
    (channel && channel.plan) ? channel.plan : ChannelPlan.default
  end

  def channel_fee
    calc_channel_fee
  end

  def calc_channel_fee
    cost - variable_costs - processing_fee - chalkle_fee
  end

  def chalkle_fee(incl_tax = true)
    return 0 if free?
    single = course_class_type.nil? ? single_class? : course_class_type == 'course'
    no_tax_fee = (single ? channel_plan.course_attendee_cost : channel_plan.class_attendee_cost);
    incl_tax ? Finance.apply_sales_tax_to(no_tax_fee, country_code) : no_tax_fee
  end

  def chalkle_fee=(value)
    self.cached_chalkle_fee = value
  end

  def processing_fee
    if cost.present?
      cost * channel_plan.processing_fee_percent
    else
      calculate_cost(false) * channel_plan.processing_fee_percent
    end
  end

  def self.teacher_pay_types
    [ 'Flat fee', 'Fee per attendee', 'Not paid through chalkle']
  end

  def teacher_pay_variable
    teacher_pay_type == Course.teacher_pay_types[1] ? teacher_cost : 0
  end

  def teacher_pay_flat
    teacher_pay_type == Course.teacher_pay_types[0] ? teacher_cost : 0 
  end

  def variable_costs
    teacher_pay_variable
  end

  def fixed_costs
    teacher_pay_flat
  end

  def channel_max_income
     if max_attendee.present?
      channel_fee * max_attendee - fixed_costs
    else
      0
    end
  end

  def type
    if course_class_type.present?
      course_class_type
    else
      course? ? 'course' : 'class'
    end
  end

  def channel_min_income
    if min_attendee.present?
      channel_fee * min_attendee - fixed_costs
    else
      0
    end
  end

  def teacher_max_income
    if max_attendee.present?
      teacher_pay_variable * max_attendee
    else
      0
    end
  end

  def teacher_min_income
    if min_attendee.present?
      teacher_pay_variable * min_attendee
    else
      0
    end
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
      teacher_payment + cash_payment + chalkle_payment
    else
      attendance*( (teacher_cost.present? ? teacher_cost : 0) + chalkle_fee)
    end
  end

  def incomeco
    excl_gst(collected_turnover - total_cost)
  end

  def image
    course_image.image rescue nil
  end

  # this should be a scope
  def bookable?
    spaces_left? && start_at && start_at > DateTime.current && status == STATUS_1
  end

  def spaces_left?
    !limited_spaces? || spaces_left > 0
  end

  def spaces_left
    [(max_attendee.to_i - attendance), 0].max if limited_spaces?
  end

  def limited_spaces?
    true if max_attendee && max_attendee > 0
  end

  def published?
    status == STATUS_1
  end

  def displayable?
    status == STATUS_1 && visible == true
  end

  def valid_statuses
    VALID_STATUSES
  end

  def unpaid_count
    bookings.confirmed.visible.count - bookings.confirmed.visible.paid.count
  end

  def complete_details?
    teacher_id.present? && start_at.present? && channel && do_during_class.present? && teacher_cost.present? && venue.present?
  end

  def bookings_for(chalkler)
    if bookings.any?
      chalkler.bookings & bookings
    else
      nil
    end
  end

  def attendance
    bookings.confirmed.visible.sum(:guests) + bookings.confirmed.visible.count
  end

  def pay_involved
    (cost.present? ? cost : 0) > 0
  end

  def todo_attendee_list
    return (start_at > DateTime.current) && (start_at <= DateTime.tomorrow + 1) && pay_involved
  end

  def todo_pay_reminder
    return unpaid_count > 0 && pay_involved && ( start_at < DateTime.current + 4 )
  end

  def todo_payment_summary
    return pay_involved && ( (teacher_cost.present? ? teacher_cost : 0) > 0 ) && ( start_at < DateTime.current ) && ( start_at > DateTime.current - 2)
  end

  def set_name(name)
    return name.strip unless name.include?(':')
    parts = name.split(':')
    parts[1].strip
  end

  def copy_course
    except = %w{id created_at updated_at status start_at teacher_payment published_at chalkle_payment visible}
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

  def lesson_in_progress
    @lesson_in_progress ||= lessons.map {|lesson| lesson.between_start_and_end ? lesson : nil  }.compact.first if status == STATUS_1
  end

  def between_start_and_end
    check_start_at
    check_end_at
    start_at < DateTime.current && end_at > DateTime.current if start_at.present? && end_at.present?
  end

  def reviews?
    reviews.present?
  end

  def reviews
    []
  end

  def review_percent
    100
  end

  def venue_truncated(length=16)
    return if !venue || venue.empty?
    truncated = venue.split[0..venue[0..length].split(" ").count-1].join(" ")
    truncated[truncated.length-1] = truncated[truncated.length-1].gsub(/[^0-9A-Za-z]/, '')
    truncated
  end

  def start_at!
    new_start_at = first_lesson.start_at if first_lesson.present?
    update_column(:start_at, new_start_at) if start_at != new_start_at
  end

  def end_at!
    new_end_at = last_lesson.end_at if last_lesson.present? && last_lesson.valid?
    update_column(:end_at, new_end_at) if end_at != new_end_at
  end

  def expire_cache!
    ActionController::Base.new.expire_fragment("_course_#{id}")
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

  def update_published_at
    self.published_at ||= Time.current
  end
  
  def check_end_at
    self.end_at = last_lesson.end_at if last_lesson.present? && last_lesson.valid?
  end

  def check_start_at
    self.start_at = first_lesson.start_at if first_lesson.present?
  end

  def cache_costs
    self.cached_chalkle_fee = chalkle_fee
    self.cached_channel_fee = channel_fee
  end

  def set_url_name
    self.url_name = name.parameterize
  end

  def check_url_name
    self.url_name = name.parameterize if self.url_name.nil?
  end

end
