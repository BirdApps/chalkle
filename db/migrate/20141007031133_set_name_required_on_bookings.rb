class SetNameRequiredOnBookings < ActiveRecord::Migration
  def up
    Booking.all.each do |booking|
      booking.update_attribute('name',(booking.chalkler.present? ? booking.chalkler.name : "")) if booking.name.nil?
    end
  end

  def down
  end
end
