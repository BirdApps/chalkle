module ChalkleMeetup
  class ChannelImporter
    def initialize
      @chalkler_importer = ChalkleMeetup::ChalklerImporter.new
      @lesson_importer = ChalkleMeetup::LessonImporter.new
    end

    def import_chalklers(channel)
      if !channel.url_name.blank?
        puts "Importing chalklers for channel #{channel.name}"
        total_pages = RMeetup::Client.fetch(:members, { group_urlname: channel.url_name }).total_pages
        for i in 0...total_pages do
          results = RMeetup::Client.fetch(:members, { group_urlname: channel.url_name, offset: i })
          results.each do |data|
            @chalkler_importer.import(data, channel)
          end
        end
      end
    end

    def import_lessons(channel)
      if !channel.url_name.blank?
        puts "Importing classes for channel #{channel.name}"
        total_pages = RMeetup::Client.fetch(:events, { group_urlname: channel.url_name, status:'upcoming,past,suggested,proposed', text_format: 'plain' }).total_pages
        for i in 0...total_pages do
          results = RMeetup::Client.fetch(:events, { group_urlname: channel.url_name, status:'upcoming,past,suggested,proposed', text_format: 'plain', offset: i })
          results.each do |data|
            @lesson_importer.import(data, channel)
          end
        end
      end
    end
  end
end