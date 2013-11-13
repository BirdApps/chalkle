require 'omni_avatar/avatar'
require 'omni_avatar/null_avatar'

module OmniAvatar
  class Provider
    def self.updater
      raise NotImplementedError, "Your provider must build an updater on request"
    end

  end
end