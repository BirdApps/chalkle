begin
  namespace :mailer do

    desc "Send BookingMailer#course_reminder notices"
    task "booking_reminder", [:frequency] => :environment do
      EventLog.log("course_reminder") do
        bookings = Booking.needs_reminder
        bookings.each do |booking|

          booking.chalkler.notify.booking_reminder(booking)

          booking.update_column :reminder_mailer_sent, true
        end
      end
    end

    desc "Send BookingMailer#booking_completed notices"
    task "booking_completed", [:frequency] => :environment do
      EventLog.log("class_completed") do
        bookings = Booking.needs_booking_completed_mailer
        bookings.each do |booking|

          booking.chalkler.notify.booking_completed(booking)

          booking.update_column :booking_completed_mailer_sent, true
        end
      end
    end

  end
end
