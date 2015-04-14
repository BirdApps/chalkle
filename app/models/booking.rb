class Booking < ActiveRecord::Base

  require 'csv'

  EMAIL_VALIDATION_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  PAYMENT_METHODS = Finance::payment_methods
  attr_accessible *BASIC_ATTR = [
    :course_id, :payment_method, :booking, :name, :note_to_teacher, :cancelled_reason, :custom_fields, :payment, :payment_id, :email, :invite_chalkler
  ]
  attr_accessible *BASIC_ATTR, :chalkler_id, :chalkler, :course, :status, :cost_override, :visible, :reminder_last_sent_at, :chalkle_fee, :chalkle_gst, :chalkle_gst_number, :teacher_fee, :teacher_gst, :teacher_gst_number, :provider_fee,:teacher_payment,:teacher_payment_id,:provider_payment,:provider_payment_id,:provider_gst, :provider_gst_number, :processing_fee, :processing_gst, :as => :admin

  #booking statuses
  STATUS_6 = "unverified" #payment awaiting LPN
  STATUS_5 = "pending" #payment pending
  STATUS_4 = "refund_complete"
  STATUS_3 = "refund_pending"
  STATUS_2 = "no"
  STATUS_1 = "yes"
  VALID_STATUSES = [STATUS_1, STATUS_2, STATUS_3, STATUS_4, STATUS_5, STATUS_6]
  BOOKING_STATUSES = VALID_STATUSES

  belongs_to  :payment
  belongs_to  :course
  belongs_to  :chalkler
  belongs_to  :booker, class_name: "Chalkler", foreign_key: :booker_id
  belongs_to  :booking
  has_many    :bookings, as: :guests_bookings
  has_one     :provider, through: :course
  has_one     :teacher, through: :course
  
  has_one :teacher_payment, through: :course
  has_one :provider_payment, through: :course

  validates_presence_of :course_id, :status, :name, :chalkler_id

  validates_numericality_of :chalkle_fee, :chalkle_gst, :provider_fee, :provider_gst, :teacher_fee, :provider_fee, :processing_gst, :teacher_gst, allow_nil: false

  validates :pseudo_chalkler_email, allow_blank: true, format: { with: EMAIL_VALIDATION_REGEX, :message => "That doesn't look like a real email"  }


  scope :free, where(payment_id: nil)
  scope :not_free, joins(:payment).merge( Payment.exists?("bookings.id")  )

  scope :paid, not_free
  scope :unpaid, free

  scope :hidden, where(visible: false)
  scope :visible, where(visible: true)

  scope :displayable, where("status != ?", STATUS_5)

  scope :refund_pending, where(status: STATUS_3)  
  scope :refund_complete, where(status: STATUS_4) 

  scope :unconfirmed, visible.where(status: STATUS_5)
  scope :confirmed, where(status: STATUS_1)

  scope :course_visible, joins(:course).where('courses.visible = ?', true)

  scope :from_provider, -> (provider) { joins(:provider).where("provider_id = ?", provider.id) }

  scope :by_date, order(:created_at)
  scope :by_date_desc, order('created_at DESC')
  scope :date_between, ->(from,to) { where(:created_at => from.beginning_of_day..to.end_of_day) }
  
  scope :in_future,  -> { course_visible.joins(:course => :lessons).where( 'lessons.start_at > ?', Time.current ).uniq }

  scope :upcoming, confirmed.in_future

  scope :in_past, -> { course_visible.joins(:course => :lessons).where( 'lessons.start_at < ?', Time.current ).uniq }

  scope :needs_reminder, -> { course_visible.confirmed.where('reminder_mailer_sent != true').joins(:course).where( "courses.start_at BETWEEN ? AND ?", Time.current, (Time.current + 2.days) ).where(" courses.status='Published'").uniq }

  scope :created_week_of, ->(date) { where('created_at BETWEEN ? AND ?', date.beginning_of_week, date.end_of_week) }
  scope :created_month_of, ->(date) { where('created_at BETWEEN ? AND ?', date.beginning_of_month, date.end_of_month) }

  before_validation :set_free_course_attributes
  after_create :redistribute_flat_fee_between_bookings

  delegate :start_at, :flat_fee?, :fee_per_attendee?, :provider_pays_teacher?, :venue, :prerequisites, :teacher_id, :course_upload_image, to: :course
  delegate :first_name, :last_name, to: :chalkler
  
  serialize :custom_fields

  def custom_fields_merged
    if custom_fields.present?
      custom_fields.map{|cf| cf if cf.is_a? Hash }.compact.reduce Hash.new, :merge
    else
      Hash.new
    end
  end

  def email
    if pseudo_chalkler_email.present?
      pseudo_chalkler_email
    else
      chalkler.email if chalkler.present?
    end
  end

  def email=(email_address)
    if email_address.present? && email_address != email
      booking_chalkler = Chalkler.exists email_address
      if booking_chalkler.present?
        self.chalkler = booking_chalkler
        self.name = booking_chalkler.name
      else
        self.pseudo_chalkler_email = email_address
      end
    end
  end



  def paid
    self.payment.present? ? payment.paid_per_booking : 0
  end

  def self.needs_booking_completed_mailer
    course_visible.confirmed.where('booking_completed_mailer_sent != true').paid.select{|b| ((b.course.end_at || b.course.start_at) + 1.day) < Date.current && b.course.status=="Published" }
  end
  
  def free?
    cost == 0
  end

  def refund!
    if payment.present? && payment.refundable?
      self.status = STATUS_4
      payment.refund!(self)
      provider_payment.recalculate! if provider_payment.present?
      teacher_payment.recalculate! if teacher_payment.present?
      save
    end
  end

  def confirmed?
    status == STATUS_1
  end

  def cancel!(reason = nil, override_refund = false)
    # override_refund = true is probaby a teacher
    if status == STATUS_1
      if !override_refund && booker.present? && chalkler != booker 
        self.chalkler = booker
      else
        self.cancelled_reason = reason if reason
        self.status = 'no'
        if refundable? || override_refund
          if paid? && paid > 0
            self.status = 'refund_pending'
          end          
        end
      end
      return save
    end
    return false
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
    remove_fees
    #CHALKLE
    self.chalkle_gst_number = Finance::CHALKLE_GST_NUMBER
    self.chalkle_fee = course.chalkle_fee_no_tax
    self.chalkle_gst = course.chalkle_fee_with_tax - chalkle_fee
    
    self.processing_fee = course.processing_fee
    self.processing_gst = course.processing_fee*3/23
    self.processing_fee = course.processing_fee-self.processing_gst

    #TEACHER FEE
    if provider_pays_teacher?
        self.teacher_fee = 0
        self.teacher_gst = 0
    else
      if fee_per_attendee?
        self.teacher_fee = course.teacher_cost
      elsif flat_fee?
        #flat fees these are calculated on the outgoing_payment rather than per booking
        self.teacher_fee = course.teacher_cost / course.bookings.confirmed.count
      end
    end

    #TEACHER TAX
    if course.teacher.present? && course.teacher.tax_registered?
      self.teacher_gst_number = course.teacher.tax_number
      self.teacher_gst = teacher_fee*3/23
      self.teacher_fee = teacher_fee-teacher_gst
    else
      self.teacher_gst = 0
      self.teacher_gst_number = nil
    end

    #PROVIDER
    self.provider_fee = course.provider_fee
    if provider.tax_registered?
      self.provider_gst_number = provider.tax_number
      self.provider_gst = course.provider_fee*3/23
      self.provider_fee = self.provider_fee-self.provider_gst
    else
      self.provider_gst_number = nil
      self.provider_gst = 0
    end

    #adjust in case payment has been made already
    difference = cost - calc_cost
    if difference != 0
      #adjust processing_fee
      self.processing_fee = cost * course.provider_plan.processing_fee_percent
      self.processing_gst = self.processing_fee*3/23
      self.processing_fee = self.processing_fee-self.processing_gst

      #reset difference to adjust for processing_fee changes
      difference = cost - calc_cost

      #if payment exists then adjust provider fee to ensure the payment amount matches calc_cost
      adjustment_for_provider = difference
      adjustment_for_teacher = 0

      if provider_fee+provider_gst+difference < 0
        #if adjusted provider_fee is negative then deduct that negative amount from teacher_fee and make provider_fee 0
        adjustment_for_teacher = provider_fee+provider_gst+difference 
        self.provider_fee = 0
        self.provider_gst = 0
      else
        self.provider_fee = provider_fee+provider_gst+adjustment_for_provider
        self.provider_gst = provider_fee*3/23
        self.provider_fee = provider_fee - provider_gst
      end
      
      if adjustment_for_teacher != 0
        self.teacher_fee = teacher_fee+teacher_gst+adjustment_for_teacher
        if course.teacher.present? && course.teacher.tax_registered?
          self.teacher_gst = teacher_fee*3/23
          self.teacher_fee = teacher_fee-teacher_gst
        end
      end
    end

    cost
  end

  def apply_fees!
    fees = apply_fees
    save
    fees
  end

  def cost
    if payment.present?
      payment.paid_per_booking
    else
      calc_cost
    end
  end

  def calc_cost
    (chalkle_fee||0)+(chalkle_gst||0)+(teacher_fee||0)+(teacher_gst||0)+(provider_fee||0)+(provider_gst||0)+(processing_fee||0)+(processing_gst||0)
  end

  def cost_breakdown
    { chalkle_fee: chalkle_fee.to_f, chalkle_gst: chalkle_gst.to_f, teacher_fee: teacher_fee.to_f, teacher_gst: teacher_gst.to_f, provider_fee: provider_fee.to_f, provider_gst: provider_gst.to_f, processing_fee: processing_fee.to_f, processing_gst: processing_gst.to_f }
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
      'Incomplete Booking'
    when STATUS_6
      'Payment is being confirmed'
    else
       'Unknown status'
    end
  end

  def status_formatted
    Booking.status_formatted self.status
  end

   def self.status_color(status)
    case status
      when STATUS_1
        'success'
      when STATUS_2
        'info'
      when STATUS_3
        'danger'
      when STATUS_4
        'info'
      when STATUS_5
        'warning'
    end
  end

  def status_color
    Booking.status_color status
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
        if payment.paid_per_booking >= cost
          self.status = 'yes'
          self.save
        end
      end
    end
  end

  def image
    course.course_upload_image
  end

  def path_params
    {
      provider_url_name: provider,
      course_url_name: course,
      course_id: course,
      id: self
    }
  end

  def self.csv_for(bookings, opts = {})
    
    if opts[:as] == :super
      headings = %w{ id name email paid note_to_teacher }
    else
      headings = %w{ id name paid note_to_teacher }
    end
    
    basic_attr = headings.map &:to_s
    
    custom_fields = bookings.map(&:custom_fields_merged).map{|g| g.keys }.flatten.uniq.compact

    headings.concat custom_fields if custom_fields.present?

    CSV.generate do |csv|
      
      csv << headings

      bookings.each do |booking|
        new_row = basic_attr.map{ |field| booking.send(field) }
        
        if custom_fields.present?
          new_row.concat (custom_fields.map do |field|
            f = booking.custom_fields_merged[field]
            f.is_a?(Array) ? f.join(', ') : f 
          end)
        end
        
        csv << new_row
      end
      
    end
  end

  def self.stats_for_date_and_range(date, range)
    base_scope_for_stats = send("created_#{range}_of", date).confirmed
    {
      asp: asp_for( base_scope_for_stats ),
      asp_only_paid: asp_for( base_scope_for_stats.where('provider_fee > 0') ),
      revenue: base_scope_for_stats.inject(0){|sum, b| sum += b.cost }
    }
  end

  private

    def redistribute_flat_fee_between_bookings
      course.recalculate_bookings_fees! if course.flat_fee?
    end

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

end
