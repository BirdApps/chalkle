# encoding: UTF-8
class ChalklerMailer < ActionMailer::Base
  default from: '"chalkle°" <learn@chalkle.com>'

  def welcome(chalkler)
    @chalkler = chalkler
    mail(to: @chalkler.email, subject: I18n.t("email.chalkler.welcome.subject", name: @chalkler.name)) do |format|
      format.text { render :layout => 'standard_mailer' }
      format.html { render :layout => 'standard_mailer' }
    end
  end

end
