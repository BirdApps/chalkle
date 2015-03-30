# encoding: UTF-8
class OutgoingPaymentMailer < BaseChalkleMailer

  default from: '"chalkle°" <learn@chalkle.com>' 

  def remittance_advice(outgoing_payment)
    #TODO: send this remittance advice email!
  end

end