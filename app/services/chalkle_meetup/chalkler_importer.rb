require 'omni_avatar/providers/meetup'

module ChalkleMeetup
  class ChalklerImporter
    def initialize
      @avatar_updater = OmniAvatar::Providers::Meetup.updater
    end

    def import(data, channel)
      identity = OmniauthIdentity.where(uid: data.id.to_s, provider: 'meetup').first
      chalkler = identity.user if identity
      if chalkler.nil?
        chalkler = create_chalkler(data, channel)
      else
        update_chalkler_from_meetup(chalkler, data, identity)
        chalkler.channels << channel unless chalkler.channels.exists? channel
      end
      chalkler
    end

    private

      def create_chalkler(data, channel)
        chalkler = Chalkler.new
        identity = chalkler.identities.build(uid: data.id, provider: 'meetup')
        set_chalkler_data(chalkler, data, identity)
        chalkler.join_channels = [ channel.id ]
        chalkler.created_at = Time.at(data.joined / 1000)
        chalkler.save!
        chalkler
      end

      def update_chalkler_from_meetup(chalkler, data, identity)
        set_chalkler_data(chalkler, data, identity)
        chalkler.save
      end

      def set_chalkler_data(chalkler, data, identity)
        identity.provider_data = data.member

        chalkler.name = data.name
        chalkler.bio = data.bio

        @avatar_updater.update_from_data(chalkler.avatars, data)
      end
  end
end