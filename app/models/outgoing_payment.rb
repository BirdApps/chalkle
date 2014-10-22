class OutgoingPayment < ActiveRecord::Base
  attr_accessible :bookings, :teacher_id, :teacher, :channel_id, :channel, :paid_date, :fee, :tax, :status,:bank_account, :tax_number, :reference, :as => :admin

  STATUS_1 = "pending"
  STATUS_2 = "approved"
  STATUS_3 = "invoiced"
  STATUS_4 = "marked_paid"
  STATUS_5 = "confirmed_paid"
  STATUSES = [STATUS_1,STATUS_2,STATUS_4]

  scope :pending, where(status: STATUS_1)
  scope :approved, where(status: STATUS_2)
  scope :invoiced, where(status: STATUS_3)
  scope :marked_paid, where(status: STATUS_4)
  scope :confirmed_paid, where(status: STATUS_5)

  belongs_to :teacher, class_name: 'ChannelTeacher'
  belongs_to :channel

  has_many :channel_bookings, class_name: 'Booking', foreign_key: :channel_payment_id
  has_many :teacher_bookings, class_name: 'Booking', foreign_key: :teacher_payment_id
  
  has_many :teacher_payments, through: :teacher_bookings, source: :payments
  has_many :channel_payments, through: :channel_bookings, source: :payments
  
  has_many :teacher_courses, through: :teacher_bookings, source: :course, foreign_key: :course_id
  has_many :channel_courses, through: :channel_bookings, source: :course, foreign_key: :course_id

  def self.pending_payment_for_teacher(teacher)
    OutgoingPayment.where(status: STATUS_1, teacher_id: teacher.id).first || OutgoingPayment.create({teacher: teacher, status: STATUS_1, tax: 0, fee: 0, tax_number: teacher.tax_number, bank_account: teacher.account }, as: :admin)
  end

  def self.pending_payment_for_channel(channel)
    OutgoingPayment.where(status: STATUS_1, channel_id: channel.id).first || OutgoingPayment.create({channel: channel, status: STATUS_1, tax: 0, fee: 0, tax_number: channel.tax_number, bank_account: channel.account }, as: :admin)
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
    end
  end

  def status_formatted
    OutgoingPayment.status_formatted(status)
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
      teacher_courses
    else
      channel_courses
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
      teacher_bookings.where("teacher_fee > 0") 
    else
      channel_bookings.where("provider_fee > 0") 
    end
  end

  def calc_fee
    self.fee = bookings.inject(0){|sum,b| sum += ( for_teacher? ? b.teacher_fee : b.provider_fee ) }
  end

  def calc_tax
    self.tax = bookings.inject(0){|sum,b| sum += ( for_teacher? ? b.teacher_gst : b.provider_gst ) }
  end

  #only calculate fee and tax only before approval
  def total
    if status == STATUS_1
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