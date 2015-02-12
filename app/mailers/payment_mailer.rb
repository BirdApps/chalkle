# encoding: UTF-8
class PaymentMailer < BaseChalkleMailer

  default from: '"chalkle°" <learn@chalkle.com>' 

  def receipt_to_chalkler(payment)
    @payment = payment
    @chalkler = payment.chalkler
    @course = payment.course
    @provider = @course.provider
    @no_hello = true
    @skip_unsubscribe = true
    
    mail(to: @chalkler.email,  subject: I18n.t("payment.receipt.subject", name: @chalkler.first_name, course_name: @course.name)) do |format| 
      format.text { render layout: 'standard_mailer' }
      format.html { render layout: 'standard_mailer' }
    end
  end

end
