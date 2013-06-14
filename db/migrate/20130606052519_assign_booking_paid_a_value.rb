class AssignBookingPaidAValue < ActiveRecord::Migration
  def up
    Booking.where{ paid == nil }.each do |booking|
      booking.update_attribute :paid, false
    end
  end

  def down
  end
end
