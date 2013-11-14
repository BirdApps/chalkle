require 'omni_avatar/null_object'

module OmniAvatar
  class NullAvatar < NullObject
    def url
      '/assets/omni_avatar/avatar-blank-100x100.jpg'
    end
  end
end