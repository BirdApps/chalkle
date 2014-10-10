class OutgoingPayment < ActiveRecord::Base
  attr_accessible :bookings, :teacher_id, :teacher, :channel_id, :channel, :paid_date, :fee, :tax, :status,:bank_account, :tax_number, :reference, :as => :admin

  STATUS_1 = "pending"
  STATUS_2 = "approved"
  STATUS_3 = "invoiced"
  STATUS_4 = "marked_paid"
  STATUS_5 = "confirmed_paid"
  STATUSES = [STATUS_1,STATUS_2,STATUS_3]

  belongs_to :teacher, class_name: 'ChannelTeacher'
  belongs_to :channel

  has_many :channel_bookings, class_name: 'Booking', foreign_key: :channel_payment_id
  has_many :teacher_bookings, class_name: 'Booking', foreign_key: :teacher_payment_id
  has_many :payments, through: :bookings

  def self.pending_payment_for_teacher(teacher)
    OutgoingPayment.where(status: STATUS_1, teacher_id: teacher.id).first || OutgoingPayment.create({teacher: teacher, status: STATUS_1, tax: 0, fee: 0, tax_number: teacher.tax_number, bank_account: teacher.account }, as: :admin)
  end

  def self.pending_payment_for_channel(channel)
    OutgoingPayment.where(status: STATUS_1, channel_id: channel.id).first || OutgoingPayment.create({channel: channel, status: STATUS_1, tax: 0, fee: 0, tax_number: channel.tax_number, bank_account: channel.account }, as: :admin)
  end

  #TODO: run at midnight every night
  def self.create_pending_payments
    courses = Course.need_outgoing_payments
    payments = []
    courses.each do |course|
      teacher_payment = OutgoingPayment.pending_payment_for_teacher course.teacher
      channel_payment = OutgoingPayment.pending_payment_for_channel course.channel

      course.bookings.each do |booking|
        booking.teacher_payment_id = teacher_payment.id
        booking.channel_payment_id = channel_payment.id   
        booking.save
      end
      payments << teacher_payment
      payments << channel_payment
    end
    payments
  end

  def for_teacher?
    teacher.present?
  end

  def for_channel?
    channel.present?
  end

  def bookings
    channel_bookings + teacher_bookings
  end

  def total
    if status == STATUS_1
      total = 0
      bookings.each do |booking|
        if for_teacher?
          total += booking.teacher_fee
          total += booking.teacher_gst
        elsif for_channel?
          total += booking.provider_fee
          total += booking.provider_gst
        end
      end
      total
    else
      fee+tax
    end
  end

  #calculate fee and tax only once is approved
  def approve!
    bookings.each do |booking|
      if for_teacher?
        self.fee += booking.teacher_fee
        self.tax += booking.teacher_gst
      elsif for_channel?
        self.fee += booking.provider_fee
        self.tax += booking.provider_gst
      end
    end
    self.status = STATUS_2
    save
  end

  def received_invoice!
    self.status = STATUS_3
  end


  def marked_paid!(reference = nil)
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