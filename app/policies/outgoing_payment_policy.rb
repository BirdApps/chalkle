class OutgoingPaymentPolicy < ApplicationPolicy
  attr_reader :user, :outgoing_payment

  def initialize(user, outgoing_payment)
    @user = user
    @outgoing_payment = outgoing_payment
  end

end