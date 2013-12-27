module Finance
  module ClassCostCalculators
    class FlatRateMarkup
      DEFAULT_RATES = {
        channel_fee: 2.0,
        chalkle_fee: 2.0
      }

      def initialize(lesson, tax = Tax::NzGst.new, rates = nil)
        @lesson = lesson
        @tax = tax
        @rates = rates || DEFAULT_RATES
      end

      def channel_fee
        @rates[:channel_fee]
      end

      def chalkle_fee
        @tax.apply_to @rates[:chalkle_fee]
      end

      def rounding
        fees = all_fees_without_rounding
        fees.ceil.to_f - fees
      end

      def default_chalkle_percentage
        raise NotImplementedError
      end

      def chalkle_percentage
        raise NotImplementedError
      end

      def default_channel_percentage
        raise NotImplementedError
      end

      def channel_percentage
        raise NotImplementedError
      end

      def teacher_percentage
        raise NotImplementedError
      end

      private

      attr_reader :lesson
      delegate :teacher_cost, :channel_percentage_override, :chalkle_percentage_override, :channels, :cost, to: :lesson

      def all_fees_without_rounding
        channel_fee + chalkle_fee + teacher_cost
      end
    end
  end
end