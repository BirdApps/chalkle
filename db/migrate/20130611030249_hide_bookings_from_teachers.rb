class HideBookingsFromTeachers < ActiveRecord::Migration
  def up
    bookings = Booking.where{ lesson_id != nil }
    bookings.each do |booking|
      next if booking.lesson.nil?
      if booking.teacher? and (booking.guests == 0 or booking.guests.nil?)
        booking.update_attribute :visible, false
      end
    end
  end

  def down
  end
end
