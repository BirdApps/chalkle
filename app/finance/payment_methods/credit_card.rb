module Finance
  module PaymentMethods
    class CreditCard < Base
      def label
        'Credit or Debit Card'
      end
    end
  end
end