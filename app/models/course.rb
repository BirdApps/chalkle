require 'carrierwave/orm/activerecord'
require 'course_upload_image_uploader'

class Course < ActiveRecord::Base
  GST = 0.15

  attr_accessible *BASIC_ATTR = [
    :name, :status, :visible, :course_type, :teacher_id, :do_during_class, :learning_outcomes, :max_attendee, :min_attendee, :prerequisites, :additional_comments, :venue, :provider, :provider_id, :suggested_audience, :street_number, :street_name, :city, :region, :postal_code, :longitude, :latitude, :teacher, :course_upload_image, :venue_address, :cost, :teacher_cost, :course_class_type, :teacher_pay_type, :note_to_attendees, :start_at, :custom_fields
  ]

  #chalkle fee is saved exclusive of GST
  #provider fee is saved inclusive of GST
  #teacher cost is saved inclusive of GST

  #Course statuses
  STATUS_5 = "Processing"
  STATUS_4 = "Completed"
  STATUS_3 = "Preview"
  STATUS_2 = "Cancelled"
  STATUS_1 = "Published"
  VALID_STATUSES = [STATUS_1, STATUS_2, STATUS_3, STATUS_4, STATUS_5]
  PUBLIC_STATUSES = [STATUS_1, STATUS_2, STATUS_4]

  belongs_to :repeat_course
  belongs_to :provider
  belongs_to :teacher,          class_name: "ProviderTeacher"
  belongs_to :teacher_payment,  class_name: 'OutgoingPayment', foreign_key: :teacher_payment_id
  belongs_to :provider_payment,  class_name: 'OutgoingPayment', foreign_key: :provider_payment_id

  has_many  :lessons
  has_many  :bookings
  has_many  :chalklers,     through: :bookings
  has_many  :payments,      through: :bookings
  has_many  :notices,       class_name: 'CourseNotice'
  
  mount_uploader :course_upload_image, CourseUploadImageUploader

  accepts_nested_attributes_for :lessons

  serialize :custom_fields

  [:teacher, :provider].each {|resource| delegate :name, :to => resource, :prefix => true, :allow_nil => true}

  def color
    provider.header_color if provider.header_color
  end
  
  #Time span for classes requiring attention
  PAST = 3
  IMMEDIATE_FUTURE = 5
  WEEK = 7

  validates_presence_of :name
  validates_presence_of :lessons, if: :published?
  validates_presence_of :provider
  validates_presence_of :teacher
  validates_presence_of :start_at
  validates_presence_of :venue_address

  validates :status, :inclusion => { :in => VALID_STATUSES, :message => "%{value} is not a valid status"}
  validates :teacher_cost, :allow_blank => true, :numericality => {:greater_than_or_equal_to => 0, :message => "Teacher fee must be positive" }
  validates :cost, :allow_blank => true, :numericality => {:greater_than_or_equal_to => 0, :message => "Class price must be positive" }
  validates :lessons, :length => { minimum: 1 }, if: :published?

  before_validation :check_start_at
  before_validation :check_end_at
  before_validation :check_url_name

  scope :hidden, where(visible: false)
  scope :visible, where(visible: true)
  scope :start_at_between, ->(from,to) { where(:start_at => from.beginning_of_day..to.end_of_day) }
  scope :recent, visible.start_at_between(DateTime.current.advance(days: PAST), DateTime.current.advance(days: IMMEDIATE_FUTURE))
  scope :last_week, visible.start_at_between(DateTime.current.advance(weeks: -1), DateTime.current)
  scope :in_month, ->(month){ start_at_between(month.first_day, month.last_day) }
  scope :in_week, -> (week){ start_at_between(week.first_day, week.last_day) }
  scope :in_fortnight, -> (week){ start_at_between(week.first_day, (week+1).last_day) }
  
  scope :on_date, -> (date) { start_at_between(date, date) }
  scope :in_future, -> { where( "start_at >= ?", DateTime.current) }
  scope :previous, -> { where("start_at < ?", DateTime.current) }
  #TODO: replace references to previous with in_past - time consuming because previous is common word
  scope :in_past, previous
  scope :by_date, order(:start_at)
  scope :by_date_desc, order('start_at DESC')

  scope :preview, visible.where(status: STATUS_3)
  scope :on_hold, visible.where(status: STATUS_2)
  scope :completed, visible.where(status: STATUS_4)
  scope :processing, where(status: STATUS_5)
  scope :unpublished, visible.where{ status != STATUS_1 }
  scope :published, visible.where(status: STATUS_1)
  scope :is_public, visible.where(status: PUBLIC_STATUSES)
  scope :advertisable, visible.where(status: [STATUS_4, STATUS_1]) #show completed and published
  scope :paid, where("cost > 0")
  scope :taught_by, -> (teacher){ joins(:teacher).where('provider_teachers.id = ?', teacher.id) }
  scope :taught_by_chalkler, -> (chalkler){ joins(:teacher).where('provider_teachers.chalkler_id = ?', chalkler ? chalkler.id : -1) }
  scope :free, where("cost IS NULL or cost = 0")
  scope :in_provider, -> (provider){ where(provider_id: provider.id) }
  scope :not_repeat_course, where(repeat_course_id: nil)
  scope :popular, start_at_between(DateTime.current, DateTime.current.advance(days: 20))
  scope :adminable_by, -> (chalkler){ joins(:provider => :provider_admins).where('provider_admins.chalkler_id = ?', chalkler.id)}
  scope :located_within_coordinates, -> (coordinate1, coordinate2) { 
    where("latitude > ? AND latitude < ? AND longitude > ? AND longitude < ?", 
      [ coordinate1[:lat],  coordinate2[:lat] ].min, 
      [ coordinate1[:lat],  coordinate2[:lat] ].max,
      [coordinate1[:long],  coordinate2[:long]].min, 
      [coordinate1[:long],  coordinate2[:long]].max )
  }
  scope :with_income, joins(:bookings).merge(Booking.paid.confirmed).uniq

  scope :displayable, visible.published

  scope :needs_completing, where("status = '#{STATUS_1}' AND end_at < ?", DateTime.current)

  scope :similar_to, -> (course){ where(provider_id: course.provider_id, url_name: course.url_name).displayable.in_future.by_date }

  scope :need_outgoing_payments, where("cost > 0 AND (status = '#{STATUS_4}' or status = '#{STATUS_1}') AND start_at < '#{DateTime.current.to_formatted_s(:db)}' AND (teacher_payment_id IS NULL OR provider_payment_id IS NULL)")


  before_create :set_url_name
  before_save :update_published_at
  before_save :build_searchable
  before_save :save_first_lesson
  before_save :start_at!
  before_save :end_at!
  before_save :check_teacher_cost
  after_save :clear_ivars

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
        course_set.where courses[:searchable].matches_any(query_parts)
      else
        Course.where courses[:searchable].matches_any(query_parts)
      end
    end
  end

  def paid?
    cost > 0
  end

  def editable?
    status == STATUS_1 || status == STATUS_3
  end

  def publishable?
    status == STATUS_3 && start_at > DateTime.current
  end

  def unpublishable?
    published? && bookings.empty?
  end

  def cancellable?
    published? && bookings.present?
  end

  def cancel!(reason = nil)
    self.status = STATUS_2
    self.cancelled_reason = reason if reason
    bookings.each do |booking|
      booking.cancel!(reason, true)
    end
    save
  end

  def complete!
    save if complete
  end

  def complete
    check_end_at
    if end_at < DateTime.current
      #if bookings.present?
      self.status = STATUS_4
      #else
      #  self.status = STATUS_3
      #end
      # Horowhenua were adding bookings after it has finished and marked as preview. So we'll complete everything whether it has bookings or not as a quick solution.
    end
  end

  def followers
    chalklers.uniq
  end

  def followers_except(chalkler)
    unless chalkler
      followers
    else
      chalklers.where("chalklers.id != ?", chalkler.id).uniq
    end
  end

  def classes
    lessons.order(:start_at)
  end

  def time_formatted
    start_at.present? && end_at.present? ? ((class? ? DateFunctions.day_ordinal_month(start_at, true, false, true) : '')+' '+(DateFunctions.pretty_time_range(start_at,end_at))) : 'No Schedule'
  end

  def cost_formatted(stringed =  false)
    if stringed
      cost? ? '$'+cost_formatted : 'Free'
    else
      sprintf('%.2f', cost || 0)
    end
  end

  def self.status_color(status)
    case status
      when "Processing"
        'warning'
      when "Completed"
        'info'
      when "Preview"
        'danger'
      when "Cancelled"
        'default'
      when "Published"
        'success'
    end
  end

  def status_color
    Course.status_color status
  end

  def repeating_class?
    true if repeat_course.present?
  end

  def repeating?
    repeating_class?
  end

  def next_class
    if repeat_course.present?
      repetitions =  repeat_course.courses.published.order(:start_at)
      current_index = repetitions.index(self)
      repetitions[current_index+1] if current_index && repetitions[current_index+1].present?
    end
  end

  def bookings?
    bookings.present?
  end

  def address
    venue_address.gsub(', New Zealand', '') if venue_address
  end

  def address_formatted
    venue_address.gsub(',',',<br />').html_safe if venue_address
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
    lessons.sort_by{|c| c.start_at}.first
  end

  def last_lesson
    lessons.sort_by{|c| c.start_at}.last
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
    save if publish
  end

  def publish
    if start_at > DateTime.current
      self.visible = true
      self.status = "Published"
    end
  end

  #placeholder for when we go international
  def country_code
    :nz
  end


  ###
  # Costings
  ###

  def has_income?
    bookings.paid.confirmed.present?
  end

  def teacher_income_with_tax
    @teacher_income_with_tax ||= calc_teacher_income(true)
  end

  def teacher_income_no_tax
    @teacher_income_no_tax ||= calc_teacher_income(false)
  end

  def provider_income_with_tax
    @provider_income_with_tax ||= calc_provider_income(true)
  end

  def provider_income_no_tax
    @provider_income_no_tax ||= calc_provider_income(false)
  end

  def provider_income_tax
    provider.tax_registered? ? provider_income_no_tax*0.15 : 0
  end

  def teacher_income_tax
    teacher.tax_registered? ? teacher_income_no_tax*0.15 : 0
  end

  def provider_plan
    @provider_plan ||= calc_provider_plan
  end

  def chalkle_fee
    chalkle_fee_with_tax
  end

  def chalkle_fee_with_tax
    @chalkle_fee_with_tax ||= calc_chalkle_fee(true)
  end

  def chalkle_fee_no_tax
    @chalkle_fee_no_tax ||= calc_chalkle_fee(false)
  end

  def provider_fee
    @provider_fee ||= calc_provider_fee
  end

  def processing_fee
    if cost.present?
      cost * provider_plan.processing_fee_percent
    else
      0
    end
  end

  def flat_fee?
    teacher_pay_type == Course.teacher_pay_types[0]
  end

  def fee_per_attendee?
    teacher_pay_type == Course.teacher_pay_types[1]
  end

  def provider_pays_teacher?
    teacher_pay_type == Course.teacher_pay_types[2]
  end

  def self.teacher_pay_types
    [ 'Flat fee', 'Fee per attendee', 'Provider pays teacher']
  end

  def teacher_pay_variable
    fee_per_attendee? ? teacher_cost : 0
  end

  def teacher_pay_flat
    flat_fee? ? teacher_cost : 0 
  end

  def variable_costs
    teacher_pay_variable
  end

  def fixed_costs
    teacher_pay_flat
  end

  def provider_max_income
     if max_attendee.present?
      provider_fee * max_attendee - fixed_costs
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

  def provider_min_income
    if min_attendee.present?
      provider_fee * min_attendee - fixed_costs
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
    if teacher_pay_variable.present? && min_attendee.present?
      teacher_pay_variable * min_attendee
    else
      0
    end
  end

  def image
    course_upload_image.image rescue nil
    if course_upload_image.present?
      course_upload_image 
    elsif provider.logo.present?
      provider.logo
    elsif provider.hero.present?
      provider.hero
    end
  end

  # this should be a scope
  def bookable?
    spaces_left? && start_at && start_at > DateTime.current && status == STATUS_1
  end

  def in_future?
    start_at > DateTime.current 
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

  def cancelled?
    status == STATUS_2
  end

  def completed?
    status == STATUS_4
  end

  def published?
    status == STATUS_1
  end

  def displayable?
    status == STATUS_1 && visible == true
  end

  def has_public_status?
    PUBLIC_STATUSES.include? status
  end

  def valid_statuses
    VALID_STATUSES
  end

  def bookings_for(chalkler)
    if bookings.any?
      (chalkler.bookings.visible+chalkler.booker_only_bookings) & bookings
    else
      []
    end
  end

  def attendance
    bookings.confirmed.visible.count
  end

  def free?
    cost == 0
  end

  def path
    if provider.nil?
      self.provider = Course.find(self.id).provider
    end
    "/#{provider.url_name}/#{url_name}/#{id}"
  end

  def path_series
    "/#{provider.url_name}/#{url_name}"
  end

  def lesson_in_progress
    @lesson_in_progress ||= lessons.map {|lesson| lesson.between_start_and_end ? lesson : nil  }.compact.first if status == STATUS_1 && bookings.confirmed.count > 0
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
    update_attribute("start_at", new_start_at) if start_at != new_start_at
  end

  def end_at!
    new_end_at = last_lesson.end_at if last_lesson.present? && last_lesson.valid?
    update_attribute("end_at", new_end_at) if end_at != new_end_at
  end

  def create_outgoing_payments!
    unless self.teacher_payment || teacher.nil?
      t_payment = OutgoingPayment.pending_payment_for_teacher(teacher)
      self.update_column('teacher_payment_id', t_payment.id)
    end
    unless self.provider_payment
      c_payment = OutgoingPayment.pending_payment_for_provider(provider) 
      self.update_column('provider_payment_id', c_payment.id)
    end
  end

  def call_to_action
    if limited_spaces? && !spaces_left?
      'Fully booked'
    else
      'Book now'
    end
  end

  def name=(name) 
    write_attribute :name, name 
    if status == STATUS_3 #preview
      set_url_name
    end
  end

  def build_searchable
    fields = [name, do_during_class, learning_outcomes, additional_comments, suggested_audience, venue, venue_address, note_to_attendees, prerequisites]
    fields << provider.name if provider.present?
    fields << teacher.name if teacher.present?
    self.searchable = fields.compact.join(' ').gsub(/[^0-9a-z ]/i, '').gsub(/\s+/, ' ').strip
  end

  def build_searchable!
    build_searchable
    save
  end
  
  def path_params(additional_params = {})
    params = {
      provider_url_name: provider.url_name,
      course_url_name: url_name,
      course_id: self.id
    }
    params = params.merge additional_params
    params
  end

  def recalculate_bookings_fees!
    bookings.map{|b| b.apply_fees! }
  end

  def ics
    # Create a calendar with an event (standard method)
    cal = Icalendar::Calendar.new
    cal.event do |e|
      e.dtstart     = Icalendar::Values::Date.new(self.start_at.strftime('%Y%m%dT%H%M%S'))
      e.dtend       = Icalendar::Values::Date.new(self.end_at.strftime('%Y%m%dT%H%M%S'))
      e.summary     = self.name
      e.description = self.do_during_class
      e.location    = self.address
      e.url         = "https://chalkle.com#{self.path}"
    end

    cal.publish
    cal
  end

  private

    def clear_ivars
      @provider_income_with_tax = nil
      @provider_income_no_tax = nil
      @teacher_income_with_tax = nil
      @teacher_income_no_tax = nil
      @provider_plan = nil
      @provider_fee = nil
      @chalkle_fee_with_tax = nil
      @chalkle_fee_no_tax = nil
      @first_or_new_lesson = nil
    end

    def calc_chalkle_fee(incl_tax)
      return 0 if free?
      single = course_class_type.nil? ? single_class? : course_class_type == 'course'
      fee_with_tax = (single ? provider_plan.course_attendee_cost : provider_plan.class_attendee_cost);
      !incl_tax ? Finance.remove_sales_tax_from(fee_with_tax, country_code) : fee_with_tax
    end

    def calc_provider_income(incl_tax)
      income = bookings.confirmed.paid.sum(&:provider_fee)
      income + bookings.confirmed.paid.sum(&:provider_gst) if incl_tax
      income
    end

    def calc_provider_plan
      (provider && provider.plan) ? provider.plan : ProviderPlan.default
    end

    def calc_provider_fee
      (cost||0) - (variable_costs||0) - (processing_fee||0) - (chalkle_fee_with_tax||0)
    end

    def calc_teacher_income(incl_tax)
      income = bookings.confirmed.paid.sum(&:teacher_fee)
      income + bookings.confirmed.paid.sum(&:teacher_gst) if incl_tax
      income
    end

    def save_first_lesson
      @first_or_new_lesson.save if @first_or_new_lesson
    end

    def update_published_at
      self.published_at ||= Time.current if published?
    end
    
    def check_end_at
      if last_lesson.present? && last_lesson.valid?
        self.end_at = last_lesson.end_at 
      else
        self.end_at = (self.start_at || DateTime.current) + 1.hour
      end
    end

    def check_start_at
      self.start_at = first_lesson.start_at if first_lesson.present?
    end

    def set_url_name
      self.url_name = name.parameterize
    end

    def check_url_name
      self.url_name = name.parameterize if self.url_name.nil?
    end

    def check_teacher_cost
      self.teacher_cost = 0 if teacher_pay_type == Course.teacher_pay_types[2]
    end
end
