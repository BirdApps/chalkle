module Finance
  module Tax

    class NzGst
      include Gst
      TAX_RATE = gst_rate_for :nz
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