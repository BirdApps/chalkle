# encoding: UTF-8
class OutgoingPaymentMailer < BaseChalkleMailer

  default from: '"chalkle°" <accounts@chalkle.com>' 

  def remittance_advice(outgoing_payment)
    @provider = outgoing_payment.outgoing_provider
    @outgoing_payment = outgoing_payment
    @mail_header_color = @provider.header_color(:hex) if @provider.average_hero_color.present?

    subject_text = @outgoing_payment.for_provider? ? "email.outgoing_payment.paid.to_provider.subject" : "email.outgoing_payment.paid.to_teacher.subject"
    mail(to: @outgoing_payment.recipient.email,  subject: I18n.t(subject_text, provider_name: @provider.name )) do |format| 
      format.text { render layout: 'standard_mailer' }
      format.html { render layout: 'standard_mailer' }
    end

  end

end