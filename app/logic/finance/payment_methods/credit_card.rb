module Finance
  module PaymentMethods
    class CreditCard < Base
      def label
        'Credit Card'
      end
    end
  end
end