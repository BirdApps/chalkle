class Payment < ActiveRecord::Base
  attr_accessible :booking_id, :xero_id, :xero_contact_id, :xero_contact_name, :date, :complete_record_downloaded, :total, :reconciled, :reference, :visible

  belongs_to :booking
  has_one :chalkler, through: :booking

  serialize :xero_data

  validates_uniqueness_of :xero_id

  scope :unreconciled, where("reconciled IS NOT true")
  scope :show_invisible_only, where("payments.visible = 'false'")
  scope :show_visible_only, where("payments.visible = 'true'")

  default_scope order("date desc")

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
      Payment.create(
        xero_id: t.bank_transaction_id,
        reference: t.reference,
        xero_contact_id: t.contact.id,
        xero_contact_name: t.contact.name,
        date: t.date
      )
    end
  end

  def complete_record_download
    transaction = Payment.xero.BankTransaction.find(xero_id)
    self.total = transaction.total
    self.complete_record_downloaded = true
    self.visible = true
    save
  end

end
