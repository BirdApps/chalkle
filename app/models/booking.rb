class Booking < ActiveRecord::Base
  PAYMENT_METHODS = Finance::payment_methods
  attr_accessible *BASIC_ATTR = [:course_id, :guests, :payment_method, :terms_and_conditions, :booking, :note_to_teacher ]
  attr_accessible *BASIC_ATTR, :chalkler_id, :chalkler, :course, :status, :cost_override, :paid, :visible, :reminder_last_sent_at, :chalkle_fee, :chalkle_gst, :chalkle_gst_number, :teacher_fee, :teacher_gst, :teacher_gst_number, :provider_fee, :provider_gst, :provider_gst_number, :processing_fee, :processing_gst, :as => :admin

  attr_accessor :terms_and_conditions
  attr_accessor :enforce_terms_and_conditions

  #booking statuses
  STATUS_4 = "no-show"
  STATUS_3 = "waitlist"
  STATUS_2 = "no"
  STATUS_1 = "yes"
  VALID_STATUSES = [STATUS_1, STATUS_2, STATUS_3, STATUS_4]
  BOOKING_STATUSES = %w(yes waitlist no pending no-show)

  belongs_to :course
  belongs_to :chalkler
  belongs_to :booking
  has_many :bookings, as: :guests_bookings
  has_one :payment
  has_one :channel, through: :course

  validates_presence_of :course_id, :status
  validates_presence_of :payment_method, :unless => :free?
  validates_acceptance_of :terms_and_conditions, :message => 'please read and agree', :if => :enforce_terms_and_conditions
  validates_uniqueness_of :chalkler_id, scope: :course_id, allow_blank: true

  scope :paid, where{ paid == true }
  scope :unpaid, where{ paid == false }
  scope :confirmed, where(status: STATUS_1)
  scope :waitlist, where(status: STATUS_3)
  scope :status_no, where(status: STATUS_2)
  scope :interested, where{ (status == STATUS_1) | (status == STATUS_3) | (status == STATUS_4) }
  scope :billable, joins(:course).where{ (courses.cost > 0) & (status == 'yes') & ((chalkler_id != courses.teacher_id) | (guests > 0)) }
  scope :hidden, where(visible: false)
  scope :visible, where(visible: true)
  scope :course_visible, joins(:course).where('courses.visible = ?', true)
  scope :upcoming, course_visible.joins(:course => :lessons).where( 'lessons.start_at > ?', Time.now ).order('courses.start_at')

  before_validation :set_free_course_attributes

  delegate :name, :start_at, :venue, :prerequisites, :teacher_id, :cose, to: :course, prefix: true
  delegate :free?, to: :course, allow_nil: true

 
  def name
    if course.present? && chalkler.present?
        "#{course.name} - #{chalkler.name}"
    else
      id
    end
  end

  def processing_gst_number
    chalkle_gst_number
  end

  def waive_chalkle_fee
    true
  end

  def apply_fees
    chalkle_gst_number = processing_gst_number =  Finance::CHALKLE_GST_NUMBER
    chalkle_fee = course.chalkle_fee false
    chalkle_gst = course.chalkle_fee(true) - chalkle_fee
    
    processing_fee = course.processing_fee
    processing_gst = course.processing_fee*3/23

    if course.teacher_pay_type == Course.teacher_pay_types[1]
      teacher_fee = course.teacher_cost
      if course.teacher.tax_number
        teacher_gst = teacher_fee*3/23
        teacher_gst_number = course.teacher.tax_number
      end
    end

    provider_fee = course.channel_fee
    if channel.tax_number
      provider_gst_number = channel.tax_number
      provider_gst = course.channel_fee*3/23
    end


  end

  def cost
    (chalkle_fee||0)    + (chalkle_gst||0)   +
    (teacher_fee||0)    + (teacher_gst||0)   +
    (provider_fee||0)   + (provider_gst||0)  +
    (processing_fee||0) + (processing_gst||0)
  end

  def cost_formatted
    sprintf('%.2f', cost)
  end

  def refundable?
    course_start_at > (Time.now + 3.days)
  end

  def teacher?
    return false unless course_teacher_id
    chalkler_id == course_teacher_id
  end

  def cancelled?
    (status == 'no') ? true : false
  end

  # Refactor all of this:

  def emailable
    status == 'yes' && (cost ? cost : 0) > 0 && !teacher? && (paid != true) && course_teacher_id.present?
  end

  def first_email_condition
    self.emailable && self.course.class_not_done && !self.course.class_coming_up
  end

  def second_email_condition
    self.emailable && self.course.class_coming_up && (self.chalkler.email.nil? || self.chalkler.email == "")
  end

  def third_email_condition
    self.status=='waitlist' && (self.cost.present? ? self.cost : 0) > 0 && !self.teacher? && (self.paid!=true) && self.course.class_coming_up
  end

  def reminder_after_class_condition
    self.emailable && !self.course.class_not_done
  end

  def no_show_email_condition
    self.status=='no-show' && !self.teacher? && (self.paid!=true) && !self.course.class_not_done
  end

  def reminder_email_choice
    if first_email_condition
      return 1
    elsif second_email_condition
      return 2
    elsif third_email_condition
      return 3
    elsif reminder_after_class_condition
      return 4
    elsif no_show_email_condition
      return "no-show"
    else
      return false
    end
  end

  private

  def set_free_course_attributes
    if course && free?
      self.payment_method = 'free'
      self.paid = true
    elsif course
      self.payment_method = 'credit_card'
    end
  end
end
