begin
  namespace :chalkle do

    desc "Load all payments from xero"
    task "load_payments" => :environment do
      Payment.load_all_from_xero
      Payment.where(total: 0).each {|p| p.complete_record_download} #note this will only grab the first 60 or so
    end

    desc "Pull all meetup data"
    task "load_all" => :environment do
      Rake::Task["chalkle:load_chalklers"].execute
      Rake::Task["chalkle:load_classes"].execute
      Rake::Task["chalkle:load_bookings"].execute
    end

    desc "Reprocess all meetup data"
    task "reprocess" => :environment do
      Chalkler.all.each {|c| c.set_from_meetup_data; c.save}
      Lesson.all.each {|l| l.set_from_meetup_data; l.save}
      Booking.all.each {|b| b.set_from_meetup_data; b.save}
    end

    desc "Pull chalklers from meetup"
    task "load_chalklers" => :environment do
      Group.all.each do |g|
        next unless g.api_key?
        RMeetup2::Base.api_key = g.api_key

        puts "Importing chalklers for group #{g.name}"
        result = RMeetup2::Base.get(:members, group_urlname: g.url_name, page: 1)
        c = get_page_count(result)

        for i in 0...c do
          results = RMeetup2::Base.get(:members, group_urlname: g.url_name, offset: i)
          puts results.data["meta"]
          results.data["results"].each do |r|
            Chalkler.create_from_meetup_hash(r,g)
          end
        end
      end
    end

    desc "Pull events from meetup"
    task "load_classes" => :environment do
      Group.all.each do |g|
        next unless g.api_key?
        RMeetup2::Base.api_key = g.api_key

        puts "Importing classes for group #{g.name}"
        result = RMeetup2::Base.get(:events, group_urlname: g.url_name, status:'upcoming,past,suggested,proposed', text_format: 'plain', page: 1)
        c = get_page_count(result)

        for i in 0...c do
          results = RMeetup2::Base.get(:events, group_urlname: g.url_name, status:'upcoming,past,suggested,proposed', text_format: 'plain', offset: i)
          puts results.data["meta"]
          results.data["results"].each do |r|
            Lesson.create_from_meetup_hash(r,g)
          end
        end
      end
    end

    desc "Pull rsvps from meetup"
    task "load_bookings" => :environment do
      # fix this.
      l = Lesson.where('meetup_id IS NOT NULL').collect {|l| l.meetup_id}.each_slice(100).to_a
      Group.all.each do |g|
        next unless g.api_key?
        RMeetup2::Base.api_key = g.api_key

        puts "Importing bookings for group #{g.name}"
        l.each do |event_id|
          result = RMeetup2::Base.get(:rsvps, event_id: event_id.join(','),  fields: 'host', page: 1)
          c = get_page_count(result)
          for i in 0...c do
            results = RMeetup2::Base.get(:rsvps, event_id: event_id.join(','), offset: i, fields: 'host' )
            puts results.data["meta"]
            results.data["results"].each do |r|
              Booking.create_from_meetup_hash(r)
            end
          end
        end
      end
    end

    desc 'import old data'
    task :import => :environment do
      require 'csv'
      Category.destroy_all
      Teacher.destroy_all
      Lesson.destroy_all
      csv_text = File.read(Rails.root.join('db/import/categories.csv'))
      csv = CSV.parse(csv_text, :headers => true)
      csv.each do |row|
        row = row.to_hash.with_indifferent_access
        c = Category.new
        c.id = row["id"]
        c.name = row["name"]
        c.save
      end

      csv_text = File.read(Rails.root.join('db/import/sub_categories.csv'))
      csv = CSV.parse(csv_text, :headers => true)
      teachers = {}
      csv.each do |row|
        row = row.to_hash.with_indifferent_access
        #["id", "category_id", "type", "title", "doing", "learn", "skill", "skill_note", "teacher", "teacher_qualification", "bring", "charge", "cost", "book", "note", "start", "end", "link"]

        lesson = Lesson.new
        if row["teacher"].present?
          teacher = teachers[row["teacher"]]
          if teacher.nil?
            teacher = Teacher.create(:name => row["teacher"], :qualification => row["teacher_qualification"])
            teachers[teacher.name] = teacher
          end
          lesson.teacher_id = teacher.id
        end
        lesson.category_id = row["category_id"]
        lesson.kind = row["type"]
        lesson.name = row["title"]
        lesson.doing = row["doing"]
        lesson.learn = row["learn"]
        lesson.skill = row["skill"]
        lesson.skill_note = row["skill_note"]
        lesson.bring = row["bring"]
        lesson.charge = row["charge"]
        lesson.cost = row["cost"].strip
        lesson.note = row["note"]
        lesson.start = row["start"].strip
        lesson.end = row["end"].strip
        lesson.link = row["link"].strip
        lesson.save
      end
      puts "#{Category.count} Categories"
      puts "#{Teacher.count} Teachers"
      puts "#{Lesson.count} Classes"
    end

    def get_page_count(results)
      (results.data["meta"]["total_count"].to_f / 200).ceil
    end
  end
end
