module Finance
  module Markup
    class CreditCardProcessingFee
      MARKUP_RATE = 0.04

      def initialize(rate = MARKUP_RATE)
        @rate = rate
      end

      def apply_to(value)
        value * multiplier
      end

      private

      def multiplier
        1.0 + @rate
      end
    end
  end
end