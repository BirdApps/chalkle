begin
  namespace :chalkle do

    desc "Pull chalklers from meetup" 
    task "load_chalklers" => :environment do
      for i in 0..2 do
        results = RMeetup2::Base.get(:members, group_urlname: 'sixdegrees', offset: i)
        puts results.data["meta"]
        results.data["results"].each do |r|
          Chalkler.create_from_meetup_hash(r)
        end
      end
    end

    desc "Pull events from meetup" 
    task "load_events" => :environment do
      for i in 0..1 do
        results = RMeetup2::Base.get(:events, group_urlname: 'sixdegrees', offset: i, status:'upcoming,past,suggested,proposed')
        puts results.data["meta"]
        results.data["results"].each do |r|
          Lesson.create_from_meetup_hash(r)
        end
      end
    end

    desc "Pull rsvps from meetup" 
    task "load_bookings" => :environment do
      for i in 0..8 do
        results = RMeetup2::Base.get(:rsvps, event_id: Lesson.where('meetup_id IS NOT NULL').collect {|l| l.meetup_id}.join(','), offset: i, fields: 'host' )
        puts results.data["meta"]
        results.data["results"].each do |r|
          Booking.create_from_meetup_hash(r)
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
  end
end
