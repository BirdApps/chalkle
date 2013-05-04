class Payment < ActiveRecord::Base
  attr_accessible :booking_id, :xero_id, :xero_contact_id, :xero_contact_name,
    :date, :complete_record_downloaded, :total, :reconciled, :reference,
    :visible, :cash_payment, :as => :admin

  belongs_to :booking
  has_one :chalkler, through: :booking
  has_one :lesson, through: :booking

  serialize :xero_data

  validates_uniqueness_of :xero_id
  validates_numericality_of :total, allow_nil: false

  scope :unreconciled, where("reconciled IS NOT true")
  scope :hidden, where(visible: false)
  scope :visible, where(visible: true)
  scope :cash, where(cash_payment: true)

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

  def set_metadata
    self.visible = true
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

  def complete_record_download
    transaction = Payment.xero.BankTransaction.find(xero_id)
    self.total = transaction.total
    self.complete_record_downloaded = true
    cash_payment = false
    save
  end

end
