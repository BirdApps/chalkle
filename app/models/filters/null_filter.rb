module Filters
  class NullFilter
    def overwrite_rule!(name, value)
      raise NotImplementedException
    end

    def apply_to(scope)
      scope
    end
  end
end