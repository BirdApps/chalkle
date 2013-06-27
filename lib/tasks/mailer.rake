begin
  namespace :mailer do

    desc "Send chalkler digest"
    task "chalkler_digest", [:frequency] => :environment do |t, args|
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

    desc "Send Horowhenua welcome"
    task "horowhenua_welcome" => :environment do
      chalklers = Chalkler.joins(:channels).where("channels.url_name = 'horowhenua' AND chalklers.meetup_id IS NULL")
      chalklers.each do |c|
        ChalklerMailer.horowhenua_welcome(c).deliver
      end
    end

    desc "Send 5 day reminder to pay emails"
    task "five_day_reminder" => :environment do
      chalklers = BookingReminder.load_chalklers
      chalklers.each do |c|
        reminder = BookingReminder.new(c, 5.days)
        reminder.create!
      end
    end

    desc "Send 3 day reminder to pay emails"
    task "three_day_reminder" => :environment do
      chalklers = BookingReminder.load_chalklers
      chalklers.each do |c|
        reminder = BookingReminder.new(c, 3.days)
        reminder.create!
      end
    end

  end
end
