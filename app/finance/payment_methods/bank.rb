module Finance
  module PaymentMethods
    class Bank < Base
      def label
        'Bank Transfer'
      end
    end
  end
end