class DeleteBookingsWithoutCourses < ActiveRecord::Migration
  def up
     Booking.all.each do |booking|
      booking.destroy if booking.course.nil?
    end
  end

  def down
  end
end
