require_relative 'base'

module Finance
  module ClassCostCalculators
    class PercentageCommission < Base
      def initialize(lesson = nil, options = {})
        super(lesson, options)
      end

      def channel_fee
        has_fixed_attendee_costs? ? commission_with_tax(channel_percentage) : 0
      end

      def channel_fee_description
        "#{describe_percent channel_percentage}"
      end

      def chalkle_fee
        chalkle_fee_without_rounding + rounding
      end

      def chalkle_fee_description
        "#{describe_percent chalkle_percentage} + rounding #{@tax.included_description}"
      end

      def rounding
        total_cost - all_fees_without_rounding
      end

      def total_cost
        round_up all_fees_without_rounding
      end

      def channel_percentage
        channel_value_or_default channel, :channel_rate_override, 0.125
      end

      def teacher_percentage
        channel_value_or_default channel, :teacher_percentage, 0.75
      end

      def chalkle_percentage
        1.0 - teacher_percentage - channel_percentage
      end

      def uses_percentages?
        true
      end

      def payment_methods
        [Finance::PaymentMethods::Cash.new, Finance::PaymentMethods::Bank.new, Finance::PaymentMethods::CreditCard.new]
      end

      private

        def channel_value_or_default(channel, key, default)
          channel ? channel.send(key) : default
        end

        def all_fees_without_rounding
          channel_fee + chalkle_fee_without_rounding + fixed_attendee_costs
        end

        def chalkle_fee_without_rounding
          has_fixed_attendee_costs? ? commission_with_tax(chalkle_percentage) : 0
        end

        def commission_with_tax(percentage_commission)
          @tax.apply_to(estimated_final_cost * percentage_commission)
        end

        def estimated_final_cost
          percentage = teacher_percentage

          return 0 unless percentage > 0
          fixed_attendee_costs / percentage
        end

    end
  end
end