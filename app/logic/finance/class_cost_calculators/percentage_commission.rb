module Finance
  module ClassCostCalculators
    class PercentageCommission
      def initialize(lesson, tax = Tax::NzGst.new)
        @lesson = lesson
        @tax = tax
      end

      def channel_fee
        @lesson.teacher_cost ? fee(@lesson.channel_percentage) : 0
      end

      def chalkle_fee

      end

      private

        def teacher_percentage
          1.0 - @lesson.channel_percentage - @lesson.chalkle_percentage
        end

        # SMELL: This method is poorly named. It's a duplicate equation that has been factored into a method,
        #        but it isn't clear to the user what calling this method really means.
        def fee(channel_cut)
          @tax.apply_to(estimated_final_cost * channel_cut)
        end

        def estimated_final_cost
          percentage = teacher_percentage

          return 0 unless percentage > 0
          @lesson.teacher_cost / percentage
        end

    end
  end
end