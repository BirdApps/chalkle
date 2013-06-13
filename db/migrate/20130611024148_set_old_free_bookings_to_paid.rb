class SetOldFreeBookingsToPaid < ActiveRecord::Migration
  def up
    bookings = Booking.joins{ :lesson }.where{ (lessons.cost == 0) | (lessons.cost == nil) }.readonly(false)
    bookings.each do |booking|
      unless booking.payment_method == 'free'
        booking.update_attribute :paid, true
        booking.update_attribute :payment_method, 'free'
      end
    end
  end

  def down
  end
end
