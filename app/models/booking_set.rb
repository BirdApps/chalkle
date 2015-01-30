class BookingSet
  include ActiveAttr::Model

  def initialize(booking)
    bookings << booking
  end

  def bookings
    @bookings ||= []
  end

  def count
    @bookings.count
  end

end