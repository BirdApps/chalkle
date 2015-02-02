class BookingSet
  include ActiveAttr::Model

  def initialize(params = nil)
    if params
      @bookings = params[:bookings].map{ |b| Booking.new b }
    end
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
      true
    else
      self.errors = bookings.map(&:errors).flatten
      false
    end
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

  def cost_per_booking
    bookings.first.cost if bookings.present?
  end

  def total_cost
    bookings.sum &:cost
  end

end