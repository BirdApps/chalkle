class AddBookerIdToBooking < ActiveRecord::Migration
  def up
    add_column :bookings, :booker_id, :integer
    Booking.reset_column_information
    puts Booking.all.map{ |b| b.update_column :booker_id, b.chalkler_id }.count+" bookings updated"
  end

  def down
    remove_column :bookings, :booker_id
  end
end
