require 'omni_avatar/avatar'
require 'omni_avatar/null_avatar'
require 'omni_avatar/avatar_collection'

module OmniAvatar
  module HasAvatar
    def self.included(base)
      base.has_many :avatars, class_name: 'OmniAvatar::Avatar', dependent: :destroy, as: :owner, extend: AvatarCollection
    end

    def avatar
      avatars.first || NullAvatar.new
    end

    def add_avatar(avatar)
      avatars << avatar
    end
  end
end