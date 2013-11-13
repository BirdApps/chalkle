require 'omni_avatar/provider'

module OmniAvatar
  class UrlProvider < Provider
    def build_avatar(data)
      url = external_avatar_url(data)
      if url
        build_avatar_from_url(url)
      else
        build_null_avatar(data)
      end
    end

    def external_avatar_url(data)
      raise NoMethodError, "Your UrlProvider derived class needs to implement external_avatar_url"
    end

    private

      def build_avatar_from_url(url)
        result = Avatar.new
        result.remote_image_url = url
        result
      end

      def build_null_avatar(data)
        ::OmniAvatar::NullAvatar.new
      end
  end
end