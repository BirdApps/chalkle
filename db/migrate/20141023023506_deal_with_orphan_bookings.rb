class DealWithOrphanBookings < ActiveRecord::Migration
  
  def up
    bookings = Booking.all.select{ |b| !b.valid? }
    if bookings.present?
      dummy = Chalkler.find_by_email "dummy@chalkle.com"
      dummy = Chalkler.create name: "John Doe", email: "dummy@chalkle.com" if dummy.nil?
      bookings.each do |booking|
        booking.status = 'no' if booking.status.nil?
        if booking.chalkler.nil?
          booking.chalkler = dummy
          booking.name = dummy.name 
        end
        if booking.course.nil?
          booking.destroy 
        else
          booking.save
        end
      end
    end
  end

  def down
    ActiveRecord::IrreversibleMigration
  end

end
