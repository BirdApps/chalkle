# encoding: UTF-8
class PaymentMailer < BaseChalkleMailer

  default from: '"chalkle°" <learn@chalkle.com>' 

  def receipt_to_chalkler(payment, resend=false)
    @payment = payment
    @chalkler = payment.chalkler
    @course = payment.course
    @provider = payment.provider
    @no_hello = true
    @skip_unsubscribe = true
    @mail_header_color = @course.provider.header_color(:hex)

    if !@payment.receipt_sent || resend
      mail(to: @chalkler.email,  subject: I18n.t("email.payment.receipt.subject", name: @chalkler.first_name, course_name: @course.name)) do |format| 
        format.text { render layout: 'standard_mailer' }
        format.html { render layout: 'standard_mailer' }
      end
      @payment.update_attribute :receipt_sent, true
    end
    
  end

end
