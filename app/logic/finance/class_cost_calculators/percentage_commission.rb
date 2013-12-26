module Finance
  module ClassCostCalculators
    class PercentageCommission
      def initialize(lesson, tax = Tax::NzGst.new)
        @lesson = lesson
        @tax = tax
      end

      def channel_fee
        teacher_cost ? commission_with_tax(channel_percentage) : 0
      end

      def chalkle_fee
        chalkle_fee_without_rounding + rounding
      end

      def rounding
        cost ? cost - all_fees_without_rounding : 0
      end

      private

        attr_reader :lesson
        delegate :teacher_cost, :channel_percentage, :chalkle_percentage, :cost, to: :lesson

        def all_fees_without_rounding
          channel_fee + chalkle_fee_without_rounding + (teacher_cost || 0)
        end

        def chalkle_fee_without_rounding
          teacher_cost ? commission_with_tax(chalkle_percentage) : 0
        end

        def teacher_percentage
          1.0 - channel_percentage - chalkle_percentage
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