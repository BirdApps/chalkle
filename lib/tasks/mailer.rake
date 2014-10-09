begin
  namespace :mailer do

    desc "Send BookingMailer#course_reminder notices"
    task "booking_reminder", [:frequency] => :environment do
      EventLog.log("course_reminder") do
        bookings = Booking.needs_reminder
        bookings.each do |booking|
          BookingMailer.booking_reminder(booking).deliver!
          booking.update_column :reminder_mailer_sent, true
        end
      end
    end

    desc "Send BookingMailer#booking_completed notices"
    task "booking_completed", [:frequency] => :environment do
      EventLog.log("class_completed") do
        bookings = Booking.needs_booking_completed_mailer
        bookings.each do |booking|
          BookingMailer.booking_completed(booking).deliver!
          booking.update_column :booking_completed_mailer_sent, true
        end
      end
    end

    desc "Send chalkler digest"
    task "chalkler_digest", [:frequency] => :environment do |t, args|
      EventLog.log("chalkler_digest_#{args.frequency}") do
        unless (args.frequency == 'daily' || args.frequency == 'weekly')
          puts "task accepts only 'weekly' or 'daily' as valid arguments"
          exit!(1)
        end
        chalklers = ChalklerDigest.load_chalklers(args.frequency)
        chalklers.each do |c|
          digest = ChalklerDigest.new c
          digest.create!
        end
      end
    end

    desc "Send Horowhenua welcome"
    task "horowhenua_welcome" => :environment do
      EventLog.log('horowhenua_welcome') do
        chalklers = Chalkler.joins(:channels).where("channels.url_name = 'horowhenua' AND chalklers.meetup_id IS NULL")
        chalklers.each do |c|
          ChalklerMailer.horowhenua_welcome(c).deliver
        end
      end
    end

    desc "Send 5 day reminder to pay emails"
    task "five_day_reminder" => :environment do
      EventLog.log('five_day_reminder') do
        chalklers = BookingReminder.load_chalklers
        chalklers.each do |c|
          reminder = BookingReminder.new(c, 5.days)
          reminder.create!
        end
      end
    end

    desc "Send 3 day reminder to pay emails"
    task "three_day_reminder" => :environment do
      EventLog.log('three_day_reminder') do
        chalklers = BookingReminder.load_chalklers
        chalklers.each do |c|
          reminder = BookingReminder.new(c, 3.days)
          reminder.create!
        end
      end
    end

  end
end
