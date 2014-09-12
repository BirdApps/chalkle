module Finance
  module PaymentMethods
    class Cash < Base
      def label
        'Cash'
      end
    end
  end
end