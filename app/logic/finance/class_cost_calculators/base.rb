module Finance
  module ClassCostCalculators
    class Base
      attr_accessor :lesson

      def initialize(lesson, options = {})
        @lesson = lesson
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
        @channel || @lesson.channel
      end

      private

        def describe_percent(fraction)
          "#{fraction * 100}%"
        end

        def describe_money(value)
          "$#{"%.2f" % value}"
        end
    end
  end
end