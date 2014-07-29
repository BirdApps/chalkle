begin
  namespace :chalkle do

    desc "Load all payments from xero"
    task "load_payments" => :environment do
      EventLog.log('load_payments') do
        Payment.load_all_from_xero
        Payment.where(total: 0).each {|p| p.complete_record_download} #note this will only grab the first 60 or so
      end
    end

    desc "Pull all meetup data"
    task "load_all" => :environment do
      EventLog.log('load_all') do
        Rake::Task["chalkle:load_chalklers"].execute
        # Rake::Task["chalkle:load_classes"].execute
        # Rake::Task["chalkle:load_bookings"].execute
        # Rake::Task["chalkle:load_venues"].execute
      end
    end

    desc "Reprocess all meetup data"
    task "reprocess" => :environment do
      EventLog.log('reprocess') do
        Chalkler.all.each {|c| c.set_from_meetup_data; c.save}
        Course.all.each {|l| l.set_from_meetup_data; l.save}
        Booking.all.each {|b| b.set_from_meetup_data; b.save}
      end
    end

    desc "Pull chalklers from meetup"
    task "load_chalklers" => :environment do
      EventLog.log('load_chalklers') do
        channel_importer = ChalkleMeetup::ChannelImporter.new

        Channel.where("url_name IS NOT NULL").all.each do |channel|
          channel_importer.import_chalklers(channel)
        end
      end
    end

    desc "Pull events from meetup"
    task "load_classes" => :environment do
      EventLog.log('load_classes') do
        channel_importer = ChalkleMeetup::ChannelImporter.new

        Channel.where("url_name IS NOT NULL").all.each do |channel|
          channel_importer.import_courses(channel)
        end
      end
    end

    desc "Pull rsvps from meetup"
    task "load_bookings" => :environment do
      EventLog.log('load_bookings') do
        booking_importer = ChalkleMeetup::BookingImporter.new

        l = Course.where('meetup_id IS NOT NULL').collect {|l| l.meetup_id}.each_slice(10).to_a
        l.each do |event_id|
          result = RMeetup::Client.fetch(:rsvps, { event_id: event_id.join(','),  fields: 'host' })
          result.each do |data|
            booking_importer.import(data)
          end
        end
      end
    end

    desc "Pull venues from meetup"
    task "load_venues" => :environment do
      EventLog.log('load_venues') do
        channels = Channel.where{(url_name == 'sixdegrees') | (url_name == 'whanau')}
        channels.each do |channel|
          puts "Importing venues for #{channel.name}"
          VenueImporter.import channel
        end
      end
    end
  end
end
