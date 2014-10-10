class OutgoingPayment < ActiveRecord::Base
  attr_accessible :bookings, :teacher_id, :teacher, :channel_id, :channel, :paid_date, :fee, :tax, :status,:bank_account,:tax_number, :reference, :as => :admin

  STATUS_1 = "pending"
  STATUS_2 = "marked_paid"
  STATUS_3 = "confirmed_paid"
  STATUS_4 = ""
  STATUSES = [STATUS_1,STATUS_2,STATUS_3]

  has_one :teacher, class_name: 'ChannelTeacher'
  has_one :channel

  has_many :bookings
  has_many :payments, through: :bookings

  def total
    fee+tax
  end
end