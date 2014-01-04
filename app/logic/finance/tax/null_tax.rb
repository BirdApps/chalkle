module Finance
  module Tax
    class NullTax

      def apply_to(value)
        value
      end

      def included_description
        nil
      end
    end
  end
end