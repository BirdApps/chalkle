module Finance
  module Tax
    class NullTax

      def apply_to(value)
        value
      end

    end
  end
end