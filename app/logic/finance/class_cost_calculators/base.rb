module Finance
  module ClassCostCalculators
    class Base
      attr_accessor :course

      def initialize(course, options = {})
        @course = course
        @channel = options[:channel]
        @tax = options[:tax] || Tax::NzGst.new
      end

      def channel_fee_description
        "unknown"
      end

      def chalkle_fee_description
        "unknown"
      end

      def channel
        @channel || @course.channel
      end

      def update_costs(course)
        course.cost = total_cost
      end

      def uses_percentages?
        false
      end

      private

        attr_reader :course
        delegate :teacher_cost, :material_cost, to: :course, allow_nil: true

        def describe_percent(fraction)
          "#{fraction * 100}%"
        end

        def describe_money(value)
          "$#{"%.2f" % value}"
        end

        def round_up(value)
          value.ceil.to_f
        end

        def fixed_attendee_costs
          (teacher_cost || 0.0) + (material_cost || 0.0)
        end

        def has_fixed_attendee_costs?
          value = fixed_attendee_costs
          value && value > 0.0
        end
    end
  end
end