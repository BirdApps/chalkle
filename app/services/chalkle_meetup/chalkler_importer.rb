module ChalkleMeetup
  class ChalklerImporter
    def import(result, channel)
      chalkler = Chalkler.find_by_meetup_id(result.id)
      if chalkler.nil?
        chalkler = create_chalkler(result, channel)
      else
        update_chalkler_from_meetup(chalkler, result)
        chalkler.channels << channel unless chalkler.channels.exists? channel
      end
      chalkler
    end

    private

      def create_chalkler(result, channel)
        chalkler = Chalkler.new
        chalkler.name = result.name
        chalkler.meetup_id = result.id
        chalkler.provider = 'meetup'
        chalkler.uid = result.id
        chalkler.bio = result.bio
        chalkler.meetup_data = result.to_json
        chalkler.join_channels = [ channel.id ]
        chalkler.save!
        chalkler
      end

      def update_chalkler_from_meetup(chalkler, result)
        chalkler.name = result.name
        chalkler.bio = result.bio
        chalkler.meetup_data = result.to_json
        chalkler.save
      end



  end
end