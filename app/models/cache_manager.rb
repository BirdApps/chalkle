class CacheManager
  class << self

    def expire_cache! 
      expire_filter_cache!
      ActionController::Base.new.expire_fragment(/_course.*/)
    end

    def expire_filter_cache!
      expire_region_filter_cache!
      expire_category_filter_cache!
      expire_channel_filter_cache!
    end

    def expire_region_filter_cache!
      ActionController::Base.new.expire_fragment(/region_filter_list.*/)
    end

    def expire_category_filter_cache!
      ActionController::Base.new.expire_fragment(/region_category_list.*/)
    end

    def expire_channel_filter_cache!
      ActionController::Base.new.expire_fragment(/region_channel_list.*/)
    end
  end
end