class AddBookingForGuests < ActiveRecord::Migration
  def up
    Booking.transaction do
      Booking.all.each do |booking|
        booking.name = booking.chalkler.name if booking.name.blank? && booking.chalkler.present?
        booking.guests.to_i.times do
          new_booking = booking.dup
          new_booking.guests = 0
          new_booking.name = booking.name.to_s+"'s guest"
          new_booking.paid = 0
          new_booking.payment = nil
          new_booking.remove_fees
          new_booking.save
          puts 'new guest booking for booking_id: '+booking.id.to_s
        end
        booking.guests = 0
        booking.save if booking.changed?
      end
    end
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
