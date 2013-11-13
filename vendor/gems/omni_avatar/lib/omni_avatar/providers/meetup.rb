require 'omni_avatar/data_updater'
require 'omni_avatar/providers/meetup/data_parser'

module OmniAvatar
  module Providers
    module Meetup
      def self.updater
        DataUpdater.new data_parser: DataParser.new, provider_name: :meetup
      end
    end
  end
end