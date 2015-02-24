class OutgoingPayment < ActiveRecord::Base
  attr_accessible :bookings, :teacher_id, :teacher, :channel_id, :channel, :paid_date, :fee, :tax, :status,:bank_account, :tax_number, :reference, :as => :admin

  STATUS_1 = "pending"
  STATUS_2 = "approved"
  STATUS_3 = "invoiced"
  STATUS_4 = "marked_paid"
  STATUS_5 = "confirmed_paid"
  STATUS_6 = "not_valid"
  STATUSES = [STATUS_1,STATUS_2,STATUS_4,STATUS_6]
  APPROVED_STATUSES = [STATUS_2,STATUS_4,STATUS_5]
  PAID_STATUSES = [STATUS_5,STATUS_4]

  scope :pending, where(status: STATUS_1)
  scope :approved, where(status: STATUS_2)
  scope :invoiced, where(status: STATUS_3)
  scope :paid, where("status = '#{STATUS_4}' OR status = '#{STATUS_5}'")
  scope :marked_paid, where(status: STATUS_4)
  scope :confirmed_paid, where(status: STATUS_5)
  scope :not_valid, where(status: STATUS_6)
 
  scope :by_date, order(:updated_at)

  belongs_to :teacher, class_name: 'ChannelTeacher'
  belongs_to :channel

  has_many :channel_courses,  class_name: 'Course', foreign_key: :channel_payment_id
  has_many :teacher_courses,  class_name: 'Course', foreign_key: :teacher_payment_id

  has_many :teacher_bookings, through: :teacher_courses,  source: :bookings
  has_many :channel_bookings, through: :channel_courses,  source: :bookings
  
  has_many :teacher_payments, through: :teacher_bookings, source: :payment
  has_many :channel_payments, through: :channel_bookings, source: :payment

  validates_presence_of :fee, :tax, :status
  validate :teacher_or_channel_presence

  def self.valid
    #TODO: OutgoingPayment.valid should be sql instead of ruby
    OutgoingPayment.select{|o| o.courses.select{ |c| (o.for_teacher? ? c.teacher_income_with_tax : c.channel_income_with_tax) != 0 }.present? }
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

  def approved?
    APPROVED_STATUSES.include? self.status
  end

  def paid?
    PAID_STATUSES.include? self.status
  end

  def not_paid?
    !paid?
  end

  def not_approved?
    !approved?
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
      teacher_bookings.confirmed.not_free
    else
      channel_bookings.confirmed.not_free
    end
  end

  def calculate!
    self.tax_number = tax_num
    self.bank_account = account
    calc_fee(true)
    calc_tax(true)
    save
  end

  def recalculate!
    unless approved?
      self.tax_number = nil
      self.bank_account = nil
      bookings.map{ |b| b.apply_fees! }
      #remove any courses which are no longer marked as published or complete
      remove_courses = courses.where("status != '#{Course::STATUS_4}' AND status != '#{Course::STATUS_1}'")
      remove_courses.update_all(channel_payment_id: nil)
      remove_courses.update_all(teacher_payment_id: nil)
      calculate!
    end
  end

  def calc_fee(recalculate = false)
    if recalculate || self.fee.blank?
      self.fee = courses.inject(0){|sum,c| sum += (for_channel? ? c.channel_income_no_tax : c.teacher_income_no_tax) }
    end
    self.fee
  end

  def calc_tax(recalculate = false)
    if self.tax.blank? || recalculate
      self.tax = courses.inject(0){|sum,c| sum+= (for_channel? ? c.channel_income_tax : c.teacher_income_tax) }
    end
    self.tax
  end

  #only calculate fee and tax only before approval
  def total(recalculate = false)
    if status == STATUS_1 || status == STATUS_6
      calc_fee(true) + calc_tax(true)
    else
      calc_fee + calc_tax
    end
  end


  #calculate fee and tax only once on approval
  def approve!
    if status == STATUS_1
      calculate!
      self.status = STATUS_2
      save
    end
    total
  end

  def received_invoice!
    self.status = STATUS_3
  end


  def mark_paid!(reference = nil)
    self.reference = reference
    self.paid_date = DateTime.current unless self.paid_date
    self.status = STATUS_4
    save
  end

  def confirm_paid!(reference = nil)
    self.reference = reference || id.to_s+'-'+Date.current.to_s
    self.status = STATUS_5
    save
  end

end