
module OmniAvatar
  module AvatarCollection
    def <<(avatar)
      if avatar
        remove_for_provider(avatar)
        super(avatar)
      end
    end

    def for_provider(name)
      all_for_provider(name).first
    end

    private

    def remove_for_provider(avatar)
      all_for_provider(avatar.provider_name).map(&:destroy)
    end

    def all_for_provider(name)
      select do |match|
        match.provider_name == name
      end
    end
  end
end