class Payment < ActiveRecord::Base
  attr_accessible :chalkler_id, :chalkler, :bookings, :xero_id, :xero_contact_id, :xero_contact_name, :date, :complete_record_downloaded, :total, :reconciled, :reference, :visible, :cash_payment, :swipe_transaction_id, :swipe_status, :swipe_name_on_card, :swipe_customer_email, :swipe_currency, :swipe_identifier_id, :swipe_token, :refunded, :as => :admin

  has_many :bookings
  has_many :courses, through: :bookings

  belongs_to :chalkler #purchaser
  serialize :xero_data

  validates_uniqueness_of :xero_id, allow_nil: true
  validates_numericality_of :total, allow_nil: false

  scope :unreconciled, where("reconciled IS NOT true")
  scope :hidden, where(visible: false)
  scope :visible, where(visible: true)
  scope :cash, where(cash_payment: true)
  scope :by_date, order(:created_at)
  scope :date_between, ->(from,to) { where(:created_at => from.beginning_of_day..to.end_of_day) }

  before_create :set_metadata

  def self.xero_consumer_key= key
    @@xero_consumer_key = key
  end

  def self.xero_consumer_secret= secret
    @@xero_consumer_secret = secret
  end

  def self.xero
    @@xero ||= Xeroizer::PrivateApplication.new(@@xero_consumer_key, @@xero_consumer_secret, "#{Rails.root}/config/xero/privatekey.pem")
  end

  def self.load_all_from_xero
    transactions = Payment.xero.BankTransaction.all(where: {type: 'RECEIVE', is_reconciled: true})
    transactions.each do |t|
      payment = Payment.new
      payment.xero_id = t.bank_transaction_id
      payment.reference = t.reference
      payment.xero_contact_id = t.contact.id
      payment.xero_contact_name = t.contact.name
      payment.date = t.date
      payment.save
    end
  end

  def channel_outgoing
    c_out = bookings.confirmed.collect(&:channel_payment)
    c_out.present? ? c_out.first : nil
  end

  def teacher_outgoing
    t_out = bookings.confirmed.collect(&:teacher_payment)
    t_out.present? ? t_out.first : nil
  end

  def outgoings
    [channel_outgoing, teacher_outgoing].uniq.compact
  end

  def total
    read_attribute(:total)-refunded
  end

  def inital_amount_paid(incl_tax = true)
    amount = read_attribute(:total)
    if !incl_tax && has_tax?
      amount = amount - amount*3/23
    end
    amount 
  end

  def calculate_tax
    unless has_tax?
      0
    else
      inital_amount_paid*3/23
    end
  end

  def refund!(booking)
    if refundable? && bookings.confirmed.include?(booking)
      self.refunded = self.refunded + booking.paid
      save
    end
  end 

  def has_tax?
    channel.tax_number.present? 
  end

  def refundable?
    #Can only refund if the money hasn't already been given to channel and teacher
    refundable = true
    refundable = channel_outgoing.not_approved? if channel_outgoing.present?
    refundable = teacher_outgoing.not_approved? if teacher_outgoing.present? && refundable
    refundable
  end

  def course
    courses.first if courses
  end

  def channel
    course.channel
  end

  def set_metadata
    self.visible = true
  end

  def complete_record_download
    transaction = Payment.xero.BankTransaction.find(xero_id)
    self.total = transaction.total
    self.complete_record_downloaded = true
    cash_payment = false
    save
  end

  def paid_per_booking(incl_tax = true)
    if incl_tax
      amount = inital_amount_paid(true)
    else
      amount = inital_amount_paid(false)
    end
    amount / bookings.count
  end

end
