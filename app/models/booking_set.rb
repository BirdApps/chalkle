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

  def bookings=(bookings)
    @bookings = bookings
  end

  def count
    @bookings.count
  end

  def save(options)
    bookings_valid = true
    bookings.each do |booking|
      booking.booker = options[:booker]
      unless booking.chalkler.present?
        booking.chalkler = options[:booker]
        booking.name = options[:booker].name unless booking.name.present?
      end
      options[:free] ? booking.remove_fees : booking.apply_fees
      bookings_valid = false unless booking.valid?
    end

    if bookings_valid
      bookings.map &:save
      course.expire_cache!
      true
    else
      the_errors = bookings.map{|b| b.errors.messages }
      false
    end
  end

  def course
    bookings.first.course
  end

  def ids
    bookings.map &:id
  end

  def id
    ids.join(',')
  end

  def names
    bookings.map &:name
  end

  def name
    names.join(',')
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

  def apply_payment(payment)
    paid = payment.total/count >= cost_per_booking
    bookings.each do |booking|
      booking.payment = payment
      if paid
        book_result = booking.confirm!
        Notify.for(booking).confirmation
      else
        #TODO: notify chalkle admin that payment didn't amount to booking cost
      end
    end
    paid
  end

end