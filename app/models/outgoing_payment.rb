class OutgoingPayment < ActiveRecord::Base
  attr_accessible :bookings, :teacher_id, :teacher, :channel_id, :channel, :paid_date, :fee, :tax, :status,:bank_account, :tax_number, :reference, :as => :admin

  STATUS_1 = "pending"
  STATUS_2 = "approved"
  STATUS_3 = "invoiced"
  STATUS_4 = "marked_paid"
  STATUS_5 = "confirmed_paid"
  STATUS_6 = "not_valid"
  STATUSES = [STATUS_1,STATUS_2,STATUS_4,STATUS_6]

  scope :pending, where(status: STATUS_1)
  scope :approved, where(status: STATUS_2)
  scope :invoiced, where(status: STATUS_3)
  scope :marked_paid, where(status: STATUS_4)
  scope :confirmed_paid, where(status: STATUS_5)
  scope :not_valid, where(status: STATUS_6)
  scope :with_valid_teacher_bookings, includes(:teacher_bookings).where("bookings.teacher_fee > 0 AND bookings.status = 'yes'")
  scope :with_valid_channel_bookings, includes(:channel_bookings).where("bookings.provider_fee > 0  AND bookings.status = 'yes'")
  scope :by_date, order(:updated_at)

  belongs_to :teacher, class_name: 'ChannelTeacher'
  belongs_to :channel

  validates_presence_of :fee, :tax, :status

  validate :teacher_or_channel_presence

  has_many :channel_bookings, class_name: 'Booking', foreign_key: :channel_payment_id
  has_many :teacher_bookings, class_name: 'Booking', foreign_key: :teacher_payment_id
  
  has_many :teacher_payments, through: :teacher_bookings, source: :payment
  has_many :channel_payments, through: :channel_bookings, source: :payment
  
  has_many :teacher_courses, through: :teacher_bookings, source: :course, foreign_key: :course_id
  has_many :channel_courses, through: :channel_bookings, source: :course, foreign_key: :course_id

  def self.valid
    (with_valid_channel_bookings+with_valid_teacher_bookings).uniq.select{|o| o.bookings.present?}
  end

  def self.pending_payment_for_teacher(teacher)
    OutgoingPayment.where(status: STATUS_1, teacher_id: teacher.id).first || OutgoingPayment.create({teacher: teacher, status: STATUS_1, tax: 0, fee: 0, tax_number: teacher.tax_number, bank_account: teacher.account }, as: :admin)
  end

  def self.pending_payment_for_channel(channel)
    OutgoingPayment.where(status: STATUS_1, channel_id: channel.id).first || OutgoingPayment.create({channel: channel, status: STATUS_1, tax: 0, fee: 0, tax_number: channel.tax_number, bank_account: channel.account }, as: :admin)
  end

  def first_booking
    bookings.order(:created_at).first
  end

  def last_booking
    bookings.order(:created_at).last
  end

  def status_color
    case status
      when "pending"
        'danger'
      when "approved"
        'warning'
      when "invoiced"
        'info'
      when "marked_paid"
        'success'
      when "confirmed_paid"
        'default'
      when "not_valid"
        'default'
    end
  end

  def status_formatted
    OutgoingPayment.status_formatted(status)
  end

  def teacher_or_channel_presence
    (teacher || channel).present?
  end

  def self.status_formatted(status)
    case status
      when "pending"
        'Pending'
      when "approved"
        'Approved'
      when "invoiced"
        'Invoiced'
      when "marked_paid"
        'Paid'
      when "confirmed_paid"
        'Paid & Verified'
       when "not_valid"
        'Not valid'
    end
  end

  def for_teacher?
    teacher.present?
  end

  def for_channel?
    channel.present?
  end

  def name
    if for_channel?
      channel.name
    else
      teacher.name
    end
  end

  def account
    if bank_account.present?
      bank_account
    else
      if for_channel?
        channel.account
      else
        teacher.account
      end
    end
  end


  def tax_num
    if tax_number.present?
      tax_number
    else
      if for_channel?
        channel.tax_number
      else
        teacher.tax_number
      end
    end
  end


  def courses
    if for_teacher?
      teacher_courses.uniq
    else
      channel_courses.uniq
    end
  end

  def payments
    if for_teacher?
      teacher_payments
    else
      channel_payments
    end
  end

  def bookings
    if for_teacher?
      teacher_bookings.confirmed.where("teacher_fee > 0")
    else
      channel_bookings.confirmed.where("provider_fee > 0")
    end
  end

  def calc_fee
    self.fee = bookings.inject(0){|sum,b| sum += b.paid? ? ( for_teacher? ? b.teacher_fee || 0 : b.provider_fee || 0 ) : 0 }
  end

  def calc_tax
    self.tax = bookings.inject(0){|sum,b| sum += ( for_teacher? ? b.teacher_gst || 0 : b.provider_gst || 0 ) }
  end

  #only calculate fee and tax only before approval
  def total
    if status == STATUS_1 || status == STATUS_6
      calc_fee
      calc_tax
    end
    fee+tax
  end

  #calculate fee and tax only once on approval
  def approve!
    if status == STATUS_1
      calc_fee
      calc_tax
      self.status = STATUS_2
      self.tax_number = tax_num
      self.bank_account = account
      save
    end
    total
  end

  def received_invoice!
    self.status = STATUS_3
  end


  def mark_paid!(reference = nil)
    self.reference = reference
    self.paid_date = DateTime.current
    self.status = STATUS_4
    save
  end

  def confirm_paid!(reference = nil)
    self.reference = reference || id.to_s+'-'+Date.current.to_s
    self.status = STATUS_5
    save
  end

end