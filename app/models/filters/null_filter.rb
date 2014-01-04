module Filters
  class NullFilter
    def overwrite_rule!(name, value)
      raise NotImplementedException
    end

    def apply_to(scope)
      scope
    end

    def current_or_empty_filter_for(name)
      Rule.new(strategy_name: name)
    end

    def view_months?
      false
    end

    def has_rules?
      false
    end

    def clear_rules!
      nil
    end
  end
end