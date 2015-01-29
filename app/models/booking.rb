class Booking < ActiveRecord::Base

  require 'csv'

  PAYMENT_METHODS = Finance::payment_methods
  attr_accessible *BASIC_ATTR = [
    :course_id, :payment_method, :booking, :name, :note_to_teacher, :cancelled_reason, :custom_fields
  ]
  attr_accessible *BASIC_ATTR, :chalkler_id, :chalkler, :course, :status, :cost_override, :visible, :reminder_last_sent_at, :chalkle_fee, :chalkle_gst, :chalkle_gst_number, :teacher_fee, :teacher_gst, :teacher_gst_number, :provider_fee,:teacher_payment,:teacher_payment_id,:channel_payment,:channel_payment_id,:provider_gst, :provider_gst_number, :processing_fee, :processing_gst, :as => :admin

  #booking statuses
  STATUS_5 = "pending" #payment pending
  STATUS_4 = "refund_complete"
  STATUS_3 = "refund_pending"
  STATUS_2 = "no"
  STATUS_1 = "yes"
  VALID_STATUSES = [STATUS_1, STATUS_2, STATUS_3, STATUS_4, STATUS_5]
  BOOKING_STATUSES = VALID_STATUSES

  belongs_to  :course
  belongs_to  :chalkler
  belongs_to  :booking
  has_many    :bookings, as: :guests_bookings
  has_one     :payment
  has_one     :channel, through: :course
  has_one     :teacher, through: :course
  
  has_one :teacher_payment, through: :course
  has_one :channel_payment, through: :course

  validates_presence_of :course_id, :status, :name, :chalkler_id

  validates_numericality_of :chalkle_fee, :chalkle_gst, :provider_fee, :provider_gst, :teacher_fee, :provider_fee, :processing_gst, :teacher_gst, allow_nil: false

  scope :free, where('NOT EXISTS (SELECT booking_id FROM payments WHERE booking_id = bookings.id)')
  scope :not_free, where('EXISTS (SELECT booking_id FROM payments WHERE booking_id = bookings.id)')

  scope :paid, not_free
  scope :unpaid, free

  scope :hidden, where(visible: false)
  scope :visible, where(visible: true)

  scope :refund_pending, where(status: STATUS_3)  
  scope :refund_complete, where(status: STATUS_4) 

  scope :unconfirmed, visible.where(status: STATUS_5)
  scope :confirmed, where(status: STATUS_1)

  scope :course_visible, joins(:course).where('courses.visible = ?', true)

  scope :by_date, order(:created_at)
  scope :by_date_desc, order('created_at DESC')
  scope :date_between, ->(from,to) { where(:created_at => from.beginning_of_day..to.end_of_day) }
  
  scope :upcoming, course_visible.joins(:course => :lessons).where( 'lessons.start_at > ?', Time.current ).order('courses.start_at')

  scope :needs_reminder, course_visible.confirmed.where('reminder_mailer_sent != true').joins(:course).where( "courses.start_at BETWEEN ? AND ?", Time.current, (Time.current + 2.days) ).where(" courses.status='Published'")

  scope :created_week_of, lambda{|date| where('created_at BETWEEN ? AND ?', date.beginning_of_week, date.end_of_week) }
  scope :created_month_of, lambda{|date| where('created_at BETWEEN ? AND ?', date.beginning_of_month, date.end_of_month) }

  before_validation :set_free_course_attributes

  after_create :expire_cache!

  delegate :start_at, :flat_fee?, :fee_per_attendee?, :provider_pays_teacher?, :venue, :prerequisites, :teacher_id, :course_upload_image, to: :course

  delegate :email, to: :chalkler

  serialize :custom_fields

  def paid
    self.payment.present? ? payment.total : 0
  end

  def self.needs_booking_completed_mailer
    course_visible.confirmed.where('booking_completed_mailer_sent != true').paid.select{|b| ((b.course.end_at || b.course.start_at) + 1.day) < Date.current && b.course.status=="Published" }
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
      refunding = false
      self.status = 'no'
      self.cancelled_reason = reason if reason
      if refundable? || override_refund
        if paid? && paid > 0
          refunding = true
          self.status = 'refund_pending'
        end
      end
      
      save
    end
  end

  def confirm!
    self.status = 'yes'
    self.visible = true
    save
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

  # apply_fees runs on:
  #   1. booking creation (initial calculation)
  #   2. course update (in case course fees allocation between provider and teacher have changes )
  #   3. outgoing_payment.calc_flat_fee (in the case of a flat_fee payment to the teacher this is the only accurate time to calculate this)

  def apply_fees
    #CHALKLE
    self.chalkle_gst_number = Finance::CHALKLE_GST_NUMBER
    self.chalkle_fee = course.chalkle_fee_no_tax
    self.chalkle_gst = course.chalkle_fee_with_tax - chalkle_fee
    
    self.processing_fee = course.processing_fee
    self.processing_gst = course.processing_fee*3/23
    self.processing_fee = self.processing_fee-self.processing_gst

    #TEACHER FEE
    if provider_pays_teacher?
        self.teacher_fee = 0
        self.teacher_gst = 0
    else
      if fee_per_attendee?
        self.teacher_fee = course.teacher_cost
      elsif flat_fee?
        #flat fees these are calculated on the outgoing_payment rather than per booking
        self.teacher_fee = 0
      end
    end

    #TEACHER TAX
    if course.teacher.present? && course.teacher.tax_number.present?
      self.teacher_gst_number = course.teacher.tax_number
      self.teacher_gst = teacher_fee*3/23
      self.teacher_fee = teacher_fee-teacher_gst
    else
      self.teacher_fee = 0
      self.teacher_gst = 0
      self.teacher_gst_number = nil
    end

    #PROVIDER
    self.provider_fee = course.channel_fee
    if channel.tax_number.present?
      self.provider_gst_number = channel.tax_number
      self.provider_gst = course.channel_fee*3/23
      self.provider_fee = self.provider_fee-self.provider_gst
    else
      self.provider_gst_number = nil
      self.provider_gst = 0
    end
    cost
  end

  def apply_fees!
    cost = apply_fees
    save
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
    start_at > (Time.current + no_refund_period_in_days.days)
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

  def pending_refund?
    status == STATUS_3 
  end

  def teacher?
    return false unless course_teacher_id
    chalkler_id == course_teacher_id
  end

  def cancelled?
    (status != 'yes') ? true : false
  end

  def swipe_confirm!
    if payment && payment.swipe_transaction_id
      wrapper = SwipeWrapper.new
      verify = wrapper.verify payment.swipe_transaction_id
      if verify['data']['transaction_approved'] == "yes"
        if payment.total >= cost
          self.status = 'yes'
          self.save
        end
      end
    end
  end

  def image
    course.course_upload_image
  end

  def self.csv_for(bookings)
    fields_for_csv = %w{ id name email paid note_to_teacher }
    custom_fields_for_csv = bookings.map(&:custom_fields).map{|g| g.keys if g.is_a? Hash}.flatten.uniq.compact
    CSV.generate do |csv|

      headings = fields_for_csv.map(&:to_s)
      headings.concat custom_fields_for_csv if custom_fields_for_csv.present?
      csv << headings

      bookings.each do |booking|
        new_row = fields_for_csv.map{ |field| booking.send(field) }
        new_row.concat custom_fields_for_csv.map{ |field| f = booking.custom_fields[field.to_sym]; f.is_a?(Array) ? f.join(', ') : f } if booking.custom_fields.is_a?(Hash) && custom_fields_for_csv.is_a?(Array)
        csv << new_row
      end
      
    end
  end

  def self.stats_for_date_and_range(date, range)
        base_scope_for_stats = send("created_#{range}_of", date)
        {
          asp: asp_for( base_scope_for_stats ),
          asp_only_paid: asp_for( base_scope_for_stats.where('provider_fee > 0') ),
          revenue: base_scope_for_stats.inject(0){|sum, b| sum += b.cost }
        }
  end

  private

    def self.asp_for(bookings)
      return 0 unless bookings.any?
      bookings.inject(0){|sum, b| sum += b.cost } / bookings.count
    end

    def set_free_course_attributes
      if course_id && free?
        self.payment_method = 'free'
      elsif course_id
        self.payment_method = 'credit_card'
      end
    end

    def expire_cache!
      course.expire_cache!
    end
end
