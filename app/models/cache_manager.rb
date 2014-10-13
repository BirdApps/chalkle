class CacheManager
  class << self

    def expire_cache!
      ActionController::Base.new.expire_fragment(/.*filter_list.*/)
      ActionController::Base.new.expire_fragment(/_course.*/)
    end

  end
end