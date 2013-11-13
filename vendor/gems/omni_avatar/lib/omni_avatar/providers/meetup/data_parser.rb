module OmniAvatar
  module Providers
    module Meetup
      class DataParser
        def url_from_data(data)
          data.photo['photo_link'] if data.photo
        end
      end
    end
  end
end