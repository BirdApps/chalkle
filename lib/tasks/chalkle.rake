begin
  namespace :chalkle do

    desc "Migration tasks"
    task "migrate_images" => :environment do 
      # provider_photo 
      #   -> "http://chalkle-production.s3.amazonaws.com/provider_photo/image/:id" 
      #   provider_photo_uploader

      providers = Provider.all.select{|c| c.logo.url =~ /amazonaws\.com.*/ }
      providers.each_with_index do |provider, index|
        provider.remote_logo_url = provider.logo.url.gsub("system/uploads/production/", "")
        provider.save
        puts "#{index+1}/#{providers.count} migrated image for: #{provider.id} - #{provider.name}\n" 
      end

      courses = Course.all.select{|c| c.course_upload_image.url =~ /amazonaws\.com.*/ }
      courses.each_with_index do |course, index|
        course.remote_course_upload_image_url = course.course_upload_image.url.gsub("system/uploads/production/", "")
        course.save
        puts "#{index+1}/#{courses.count} migrated image for: #{course.id} - #{course.name}\n" 
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
        provider_importer = ChalkleMeetup::ProviderImporter.new

        Provider.where("url_name IS NOT NULL").all.each do |provider|
          provider_importer.import_chalklers(provider)
        end
      end
    end

    desc "Pull events from meetup"
    task "load_classes" => :environment do
      EventLog.log('load_classes') do
        provider_importer = ChalkleMeetup::ProviderImporter.new

        Provider.where("url_name IS NOT NULL").all.each do |provider|
          provider_importer.import_courses(provider)
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
        providers = Provider.where{(url_name == 'sixdegrees') | (url_name == 'whanau')}
        providers.each do |provider|
          puts "Importing venues for #{provider.name}"
          VenueImporter.import provider
        end
      end
    end

    desc "Complete courses that have run"
    task "complete_courses" => :environment do
      EventLog.log('complete_courses') do
        courses = Course.needs_completing.each do |course|
          if course.complete! 
            puts "course completed - #{course.id}: #{course.name}"
            Notify.for(course).completed
          end
        end 
      end
    end

    desc "Calculate outgoing payments for teachers and providers"
    task "calculate_outgoings" => :environment do
      EventLog.log('calculate_outgoings') do
        courses = Course.need_outgoing_payments
        errors = []
          courses.each do |course|
            if course.create_outgoing_payments!
              puts "course #{course.id} outgoings calculated"
            else
              errors << course.id.to_s+": "+course.errors.messages.to_s
            end
          end
        errors.each do |error|
          puts error
        end
      end
    end

    desc "Attempt to verify unverfied payments with swipe"
    task "verify_payments" => :environment do
      EventLog.log('verify_payments') do
        bookings = Booking.unconfirmed
        bookings.each do |booking|
          if booking.swipe_confirm!
            puts "Confirmed booking #{booking.id}"
          else
            puts "Unable to confirm booking #{booking.id}"
          end
        end
      end
    end

  end
end
