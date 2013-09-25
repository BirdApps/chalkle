module ChalkleMeetup
  class ChalklerImporter
    def import(data, channel)
      chalkler = Chalkler.find_by_meetup_id(data.id)
      if chalkler.nil?
        chalkler = create_chalkler(data, channel)
      else
        update_chalkler_from_meetup(chalkler, data)
        chalkler.channels << channel unless chalkler.channels.exists? channel
      end
      chalkler
    end

    private

      def create_chalkler(data, channel)
        chalkler = Chalkler.new
        chalkler.name = data.name
        chalkler.meetup_id = data.id
        chalkler.provider = 'meetup'
        chalkler.uid = data.id
        chalkler.bio = data.bio
        chalkler.meetup_data = data.to_json
        chalkler.join_channels = [ channel.id ]
        chalkler.created_at = Time.at(data.joined / 1000)
        chalkler.save!
        chalkler
      end

      def update_chalkler_from_meetup(chalkler, data)
        chalkler.name = data.name
        chalkler.bio = data.bio
        chalkler.meetup_data = data.to_json
        chalkler.save
      end
  end
end