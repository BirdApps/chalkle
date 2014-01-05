module Finance
  module Markup
    class NullMarkup
      def apply_to(value)
        value
      end
    end
  end
end