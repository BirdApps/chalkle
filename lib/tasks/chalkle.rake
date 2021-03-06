begin
  namespace :chalkle do

    desc "Migration tasks"
    task "migrate_images" => :environment do 
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

    desc "Ensure course data is valid"
    task "validate_courses" => :environment do
      EventLog.log('validate_courses') do
        changed = (Course.all.map do |course|
          course.status = 'Preview' unless course.lessons.present?
          course.status = 'Preview' unless Course::VALID_STATUSES.include?(course.status)
          course.start_at = (Time.current - 1.year) unless course.start_at.is_a?(Time)
          course.send('check_end_at') unless course.end_at.is_a?(Time)
          course.venue_address = "No address" if course.venue_address.nil?
          course.teacher = course.provider.provider_teachers.first if course.teacher.nil?
          if course.changed.present?
            unless course.save
              course.id
            end
          end
        end ).compact.uniq
        puts "#{changed.count} course's data were still not valid"  
        puts "Their ids are as follows: #{changed.join(',')}"
      end
    end

  end
end
