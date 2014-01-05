require_relative 'base'

module Finance
  module ClassCostCalculators
    class FlatRateMarkup < Base
      DEFAULT_RATES = {
        channel_fee: 2.0,
        chalkle_fee: 2.0
      }

      def initialize(lesson = nil, options = {})
        @rates = options[:rates] || DEFAULT_RATES
        @total_markup = options[:total_markup] || Markup::CreditCardProcessingFee.new
        super(lesson, options)
      end

      def channel_fee
        @rates[:channel_fee]
      end

      def channel_fee_description
        "#{describe_money @rates[:channel_fee]}"
      end

      def chalkle_fee
        @tax.apply_to(@rates[:chalkle_fee])
      end

      def chalkle_fee_description
        "#{describe_money @rates[:chalkle_fee]} #{@tax.included_description}"
      end

      def rounding
        total_cost - all_fees_with_markup
      end

      def total_cost
        round_up all_fees_with_markup
      end

      def chalkle_percentage
        raise NotImplementedError
      end

      def channel_percentage
        raise NotImplementedError
      end

      def teacher_percentage
        raise NotImplementedError
      end

      private

        def all_fees_with_markup
          @total_markup.apply_to all_fees
        end

        def all_fees
          channel_fee + chalkle_fee + fixed_attendee_costs
        end
    end
  end
end