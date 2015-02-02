class AddBookerIdToBooking < ActiveRecord::Migration
  def up
    add_column :bookings, :booker_id, :integer
    Booking.reset_column_information
    Booking.transaction do 
      count =  Booking.all.map{ |b| b.update_column :booker_id, b.chalkler_id }.count 
      puts "#{count} bookings updated"
    end
  end

  def down
    remove_column :bookings, :booker_id
  end
end
