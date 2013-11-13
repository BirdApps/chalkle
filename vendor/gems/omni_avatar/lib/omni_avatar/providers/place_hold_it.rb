require 'omni_avatar/url_provider'

module OmniAvatar
  module Providers
    class PlaceHoldIt < UrlProvider
      def external_avatar_url(data)
        "http://placehold.it/100x100"
      end
    end
  end
end