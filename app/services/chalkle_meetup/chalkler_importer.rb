require 'omni_avatar/providers/meetup'

module ChalkleMeetup
  class ChalklerImporter
    def initialize
      @avatar_updater = OmniAvatar::Providers::Meetup.updater
    end

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
        set_chalkler_data(chalkler, data)
        chalkler.meetup_id = data.id
        chalkler.provider = 'meetup'
        chalkler.uid = data.id
        chalkler.join_channels = [ channel.id ]
        chalkler.created_at = Time.at(data.joined / 1000)
        chalkler.save!
        chalkler
      end

      def update_chalkler_from_meetup(chalkler, data)
        set_chalkler_data(chalkler, data)
        chalkler.save
      end

      def set_chalkler_data(chalkler, data)
        chalkler.name = data.name
        chalkler.bio = data.bio
        chalkler.meetup_data = data.to_json

        @avatar_updater.update_from_data(chalkler.avatars, data)
      end
  end
end