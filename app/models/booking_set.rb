class BookingSet
  include ActiveAttr::Model

  def initialize(params = nil, note_to_teacher = nil)
    if params
      @bookings = params[:bookings].map do |b|
        if note_to_teacher
          b[:note_to_teacher] = note_to_teacher  
        end
        Booking.new b
      end
    end
  end

  def the_errors
    @errors ||= []
  end

  def the_errors=(error_list)
    @errors = error_list
  end

  def bookings
    @bookings ||= []
  end

  def payments 
    #there is not meant to be many payments for a booking, but we can't guarantee that – so we're safe for once. 
    @payments ||= bookings.collect(&:payment).uniq
  end

  def bookings=(bookings)
    @bookings = bookings
  end

  def swipe_identifier
    bookings.first.swipe_identifier if bookings.first
  end

   def set_swipe_identifer!(identifier)
    bookings.each do |booking|
      booking.swipe_identifier = identifier
      booking.save
    end
    swipe_identifier
  end

  def clear_ids
    @bookings.each{ |b| b.id = nil }
  end

  def count
    @bookings.count
  end

  def booker
    bookings.first.booker if bookings.first
  end

  def save(options)
    bookings_valid = true
    bookings.each do |booking|
      booking.booker = options[:booker]
      unless booking.chalkler.present?
        booking.chalkler = options[:booker]
        booking.name = options[:booker].name unless booking.name.present?
      end
      booking.waive_fees = true if options[:free] 
      booking.apply_fees
      bookings_valid = false unless booking.valid?
    end

    if bookings_valid
      bookings.map &:save
      true
    else
      the_errors = bookings.map{|b| b.errors.messages }
      false
    end
  end

  def course
    bookings.first.course
  end

  def ids=(booking_ids)
    booking_ids = '' if booking_ids.nil?
    self.bookings = booking_ids.split('-').map{ |id| Booking.find id }
  end

  def ids
    bookings.map &:id
  end

  def id
    ids.join('-')
  end

  def names
    bookings.map &:name
  end

  def name
    names.join(',')
  end

  def status
    bookings.first.status if bookings.first
  end

  def build_payment
    payment = bookings.first.build_payment if bookings.present?
    payment.chalkler = bookings.first.booker
    payment
  end

  def cost_per_booking
    bookings.first.calc_cost if bookings.present?
  end

  def total_cost
    bookings.sum &:cost
  end

  def paid?
    [true] == bookings.map{ |b| b.paid? }.uniq
  end

  def apply_payment(payment)
    paid = payment.total/count >= cost_per_booking
    bookings.each do |booking|
      booking.payment = payment
      if paid
        booking.confirm!
      else
        #TODO: notify chalkle admin that payment didn't amount to booking cost
      end
    end

    Notify.for(self).confirmation
    Notify.for(self).send_receipt

    paid
  end

end