class Booking < ActiveRecord::Base

  require 'csv'

  PAYMENT_METHODS = Finance::payment_methods
  attr_accessible *BASIC_ATTR = [
    :course_id, :guests, :payment_method, :booking, :name, :note_to_teacher,:cancelled_reason 
  ]
  attr_accessible *BASIC_ATTR, :chalkler_id, :chalkler, :course, :status, :cost_override, :visible, :reminder_last_sent_at, :chalkle_fee, :chalkle_gst, :chalkle_gst_number, :teacher_fee, :teacher_gst, :teacher_gst_number, :provider_fee,:teacher_payment,:teacher_payment_id,:channel_payment,:channel_payment_id,:provider_gst, :provider_gst_number, :processing_fee, :processing_gst, :as => :admin

  #booking statuses
  STATUS_5 = "pending" #payment pending
  STATUS_4 = "refund_complete"
  STATUS_3 = "refund_pending"
  STATUS_2 = "no"
  STATUS_1 = "yes"
  VALID_STATUSES = [STATUS_1, STATUS_2, STATUS_3, STATUS_4, STATUS_5]
  BOOKING_STATUSES = %w(yes no refund_pending pending refund_complete)

  belongs_to :course
  belongs_to :chalkler
  belongs_to :booking
  has_many :bookings, as: :guests_bookings
  has_one :payment
  has_one :channel, through: :course
  
  belongs_to :teacher_payment, class_name: 'OutgoingPayment', foreign_key: :teacher_payment_id
  belongs_to :channel_payment, class_name: 'OutgoingPayment', foreign_key: :channel_payment_id

  validates_presence_of :course_id, :status, :name
  validates_presence_of :chalkler, unless: :chalkler_deleted
  validates_presence_of :payment_method, :unless => :free?

  scope :hidden, where(visible: false)
  scope :visible, where(visible: true)
  scope :refund_pending, where(status: STATUS_3)  
  scope :refund_complete, where(status: STATUS_4) 
  scope :unconfirmed, visible.where(status: STATUS_5)
  scope :confirmed, where(status: STATUS_1)
  scope :status_no, where(status: STATUS_2)
  scope :interested, where{ (status == STATUS_1) | (status == STATUS_5) }
  scope :billable, joins(:course).where{ (courses.cost > 0) & (status == 'yes') & ((chalkler_id != courses.teacher_id) | (guests > 0)) }
  scope :course_visible, joins(:course).where('courses.visible = ?', true)
  scope :by_date, order(:created_at)
  scope :by_date_desc, order('created_at DESC')
  scope :upcoming, course_visible.joins(:course => :lessons).where( 'lessons.start_at > ?', Time.current ).order('courses.start_at')
  scope :needs_reminder, course_visible.confirmed.where('reminder_mailer_sent != true').joins(:course).where( "courses.start_at BETWEEN ? AND ?", Time.current, (Time.current + 2.days) ).where(" courses.status='Published'")

  before_validation :set_free_course_attributes

  after_save :expire_cache!
  after_create :expire_cache!

  delegate :start_at, :venue, :prerequisites, :teacher_id, :cose, to: :course, prefix: true

  delegate :email, to: :chalkler, prefix: true

  def paid
    self.payment.present? ? payment.total : 0
  end

  def self.paid
   select{|booking| (booking.paid || 0) >= booking.cost}
  end

  def self.unpaid
   select{|booking| (booking.paid || 0) < booking.cost}
end



  def self.needs_booking_completed_mailer
    course_visible.confirmed.where('booking_completed_mailer_sent != true').paid.select{|b| b.course.end_at < Date.current && b.course.status=="Published" }
  end
  
  def free?
    cost == 0
  end

  def refund!
    self.status = STATUS_4
    save
  end

  def confirmed?
    status == STATUS_1
  end

  def cancel!(reason = nil, override_refund = false)
    if status == STATUS_1
      self.status = 'no'
      self.cancelled_reason = reason if reason
      if refundable? || override_refund
        if paid? && paid > 0
          self.status = 'refund_pending'
        end
      end
      save
      BookingMailer.booking_cancelled(self).deliver!
    end
  end

  def cancelled?
    status == STATUS_1
  end

  def paid?
    free? || paid >= cost
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
    #processing_fee inclusive of gst
    self.processing_fee = self.processing_fee-self.processing_gst

    if course.teacher_pay_type == Course.teacher_pay_types[1]
      self.teacher_fee = course.teacher_cost
      if course.teacher.present? && course.teacher.tax_number.present?
        self.teacher_gst = teacher_fee*3/23
        self.teacher_gst_number = course.teacher.tax_number
      else
        self.teacher_gst = 0
        self.teacher_gst_number = nil
      end
    end

    self.provider_fee = course.channel_fee
    if channel.tax_number.present?
      self.provider_gst_number = channel.tax_number
      self.provider_gst = course.channel_fee*3/23
      #processing_fee inclusive of gst
      self.provider_fee = self.provider_fee-self.provider_gst
    else
      self.provider_gst_number = nil
      self.provider_gst = 0
    end
    cost
  end

  def cost
    (chalkle_fee||0)+(chalkle_gst||0)+(teacher_fee||0)+(teacher_gst||0)+(provider_fee||0)+(provider_gst||0)+(processing_fee||0)+(processing_gst||0)
  end

  def cost_formatted
    sprintf('%.2f', cost)
  end

  def paid_formatted
    sprintf('%.2f', paid)
  end

  def self.status_formatted(status)
    case status 
    when STATUS_1
      'Confirmed'
    when STATUS_2
      'Cancelled'
    when STATUS_3
      'Cancelled - Pending Refund'
    when STATUS_4
      'Cancelled & Refunded'
    when STATUS_5
      'Payment is being confirmed'
    else
       'Unknown status'
    end
  end

  def status_formatted
    Booking.status_formatted self.status
  end

  def refundable?
    course_start_at > (Time.current + no_refund_period_in_days.days)
  end

  def no_refund_period_in_days
    3
  end

  def transaction_id
    payment.present? && payment.swipe_transaction_id.present? ? payment.swipe_transaction_id : "nil"
  end

  def transaction_url
    payment.present? && payment.swipe_transaction_id.present? ? "https://merchant.swipehq.com/admin/main/index.php?module=transactions&action=txn-details&transaction_id="+payment.swipe_transaction_id : '#'
  end

  def teacher?
    return false unless course_teacher_id
    chalkler_id == course_teacher_id
  end

  def cancelled?
    (status != 'yes') ? true : false
  end

  def self.csv_for(bookings)
    fields_for_csv = %w{ id name chalkler_email paid note_to_teacher }
    CSV.generate do |csv|
      csv << fields_for_csv.map(&:to_s)
      bookings.each do |booking| 
        csv << fields_for_csv.map do |field| booking.send(field) 
        end
      end
    end
  end

  private
    def set_free_course_attributes
      if course && free?
        self.payment_method = 'free'
      elsif course
        self.payment_method = 'credit_card'
      end
    end

    def expire_cache!
      course.expire_cache!
    end
end
