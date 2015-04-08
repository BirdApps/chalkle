class OutgoingPaymentPolicy < ApplicationPolicy

  def initialize(user, outgoing_payment)
    @user = user
    @outgoing_payment = outgoing_payment
  end

  def show?
    @user.super? or @outgoing_payment.paid?
  end

end
