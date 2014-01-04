module Finance
  module Tax
    class NzGst
      TAX_RATE = 0.15

      def apply_to(value)
        value * multiplier
      end

      def included_description
        "+ GST"
      end

      private

        def multiplier
          1.0 + TAX_RATE
        end
    end
  end
end