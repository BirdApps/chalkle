module Finance
  module PaymentMethods
    class Base
      def name
        self.class.name.split('::').last.underscore
      end

      def label
        name
      end
    end
  end
end