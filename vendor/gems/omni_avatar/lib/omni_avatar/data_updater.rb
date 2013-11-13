require 'spec_helper'
require 'omni_avatar/avatar'

module OmniAvatar
  class DataUpdater
    def initialize(options = {})
      @parser = options[:data_parser]
      @provider_name = options[:provider_name]
    end

    def update_from_data(collection, data)
      url = @parser.url_from_data(data)
      return unless url

      if needs_updating?(collection, url)
        avatar = build_avatar_from_url(url)
        collection << avatar
      end
    end

    private

      def needs_updating?(collection, url)
        old = existing(collection)
        !old || old.original_url != url
      end

      def existing(collection)
        collection.for_provider(@provider_name)
      end

      def build_avatar_from_url(url)
        result = Avatar.new
        result.remote_image_url = url
        result.original_url = url
        result.provider_name = @provider_name
        result
      end
  end
end