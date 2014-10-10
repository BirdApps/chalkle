class Booking < ActiveRecord::Base
  PAYMENT_METHODS = Finance::payment_methods
  attr_accessible *BASIC_ATTR = [
    :course_id, :guests, :payment_method, :booking, :name, :note_to_teacher,:cancelled_reason 
  ]
  attr_accessible *BASIC_ATTR, :chalkler_id, :chalkler, :course, :status, :cost_override, :paid, :visible, :reminder_last_sent_at, :chalkle_fee, :chalkle_gst, :chalkle_gst_number, :teacher_fee, :teacher_gst, :teacher_gst_number, :provider_fee , :provider_gst, :provider_gst_number, :processing_fee, :processing_gst, :as => :admin

  #booking statuses
  STATUS_5 = "pending" #payment pending
  STATUS_4 = "refund_complete"
  STATUS_3 = "refund_pending"
  STATUS_2 = "no"
  STATUS_1 = "yes"
  VALID_STATUSES = [STATUS_1, STATUS_2, STATUS_3, STATUS_4]
  BOOKING_STATUSES = %w(yes no refund_pending refund_complete)

  belongs_to :course
  belongs_to :chalkler
  belongs_to :booking
  has_many :bookings, as: :guests_bookings
  has_one :payment
  has_one :channel, through: :course
  
  has_one :teacher_payment, class_name: 'OutgoingPayment'
  has_one :channel_payment, class_name: 'OutgoingPayment'

  validates_presence_of :course_id, :status, :name, :chalkler
  validates_presence_of :payment_method, :unless => :free?

  scope :paid, where{ cost <= paid }
  scope :unpaid, where{ cost > paid }
  scope :confirmed, where(status: STATUS_1)
  scope :waitlist, where(status: STATUS_3)
  scope :status_no, where(status: STATUS_2)
  scope :interested, where{ (status == STATUS_1) | (status == STATUS_3) | (status == STATUS_4) }
  scope :billable, joins(:course).where{ (courses.cost > 0) & (status == 'yes') & ((chalkler_id != courses.teacher_id) | (guests > 0)) }
  scope :hidden, where(visible: false)
  scope :visible, where(visible: true)
  scope :course_visible, joins(:course).where('courses.visible = ?', true)
  scope :by_date, order(:created_at)
  scope :by_date_desc, order('created_at DESC')
  scope :upcoming, course_visible.joins(:course => :lessons).where( 'lessons.start_at > ?', Time.current ).order('courses.start_at')
  scope :needs_reminder, course_visible.where('reminder_mailer_sent != true').joins(:course).where( "courses.start_at BETWEEN ? AND ?", Time.current, (Time.current + 2.days) ).where(" courses.status='Published'")

  before_validation :set_free_course_attributes

  delegate :start_at, :venue, :prerequisites, :teacher_id, :cose, to: :course, prefix: true

  def self.needs_booking_completed_mailer
    course_visible.where('booking_completed_mailer_sent != true').select{|b| b.course.end_at > Date.current && b.course.status=="Published"}
  end
  
  def free?
    cost == 0
  end

  def refund!
    self.status = STATUS_4
    save
  end

  def confirmed?
    true if status == STATUS_1
  end

  def cancel!(reason = nil)
    self.status = 'no'
    self.cancelled_reason = reason if reason
    if refundable?
      if paid? && paid > 0
        self.status = 'refund_pending'
      end
    end
    save
    BookingMailer.booking_cancelled(self).deliver!
  end

  def cancelled?
    true if status == STATUS_1 || status == STATUS_5
  end

  def paid?
    true if free? || paid == cost
  end

  def processing_gst_number
    chalkle_gst_number
  end

  def remove_fees
    self.chalkle_fee = self.processing_fee = self.chalkle_gst = self.teacher_fee = self.teacher_gst = self.provider_fee = self.processing_gst = self.provider_gst = 0
  end

  def apply_fees
    self.chalkle_gst_number =  Finance::CHALKLE_GST_NUMBER
    self.chalkle_fee = course.chalkle_fee false
    self.chalkle_gst = course.chalkle_fee(true) - chalkle_fee
    
    self.processing_fee = course.processing_fee
    self.processing_gst = course.processing_fee*3/23

    if course.teacher_pay_type == Course.teacher_pay_types[1]
      self.teacher_fee = course.teacher_cost
      if course.teacher.tax_number
        self.teacher_gst = teacher_fee*3/23
        self.teacher_gst_number = course.teacher.tax_number
      end
    end

    self.provider_fee = course.channel_fee
    if channel.tax_number
      self.provider_gst_number = channel.tax_number
      self.provider_gst = course.channel_fee*3/23
    end
    cost
  end

  def cost
    (chalkle_fee||0)+(chalkle_gst||0)+(teacher_fee||0)+(teacher_gst||0)+(provider_fee||0)+(provider_gst||0)+(processing_fee||0)+(processing_gst||0)
  end

  def cost_formatted
    sprintf('%.2f', cost)
  end

  def refundable?
    course_start_at > (Time.current + no_refund_period_in_days.days)
  end

  def no_refund_period_in_days
    3
  end

  def teacher?
    return false unless course_teacher_id
    chalkler_id == course_teacher_id
  end

  def cancelled?
    (status != 'yes') ? true : false
  end

  private

  def set_free_course_attributes
    if course && free?
      self.payment_method = 'free'
    elsif course
      self.payment_method = 'credit_card'
    end
  end
end
