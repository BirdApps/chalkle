module Finance
  module Tax
    def self.gst_rate_for(tax_code = :nz)
      case tax_code
      when :nz
        0.15
      else
        0
      end
    end

    class NzGst
      include Tax
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