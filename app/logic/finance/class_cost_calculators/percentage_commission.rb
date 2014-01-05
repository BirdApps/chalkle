require_relative 'base'

module Finance
  module ClassCostCalculators
    class PercentageCommission < Base
      def initialize(lesson = nil, options = {})
        super(lesson, options)
      end

      def channel_fee
        teacher_cost ? commission_with_tax(channel_percentage) : 0
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

      def chalkle_percentage
        channel_value_or_default channel, :chalkle_percentage, 0.125
      end

      def channel_percentage
        channel_value_or_default channel, :channel_percentage, 0.125
      end

      def teacher_percentage
        1.0 - channel_percentage - chalkle_percentage
      end

      private

        def channel_value_or_default(channel, key, default)
          channel ? channel.send(key) : default
        end

        def all_fees_without_rounding
          channel_fee + chalkle_fee_without_rounding + (teacher_cost || 0)
        end

        def chalkle_fee_without_rounding
          teacher_cost ? commission_with_tax(chalkle_percentage) : 0
        end

        def commission_with_tax(percentage_commission)
          @tax.apply_to(estimated_final_cost * percentage_commission)
        end

        def estimated_final_cost
          percentage = teacher_percentage

          return 0 unless percentage > 0
          teacher_cost / percentage
        end

    end
  end
end