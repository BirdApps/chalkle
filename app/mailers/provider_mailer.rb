# encoding: UTF-8
class ProviderMailer < BaseChalkleMailer

  default from: '"chalkle°" <learn@chalkle.com>'

  def contact(provider_contact)
    @provider_contact = provider_contact
    @mail_header_color = @provider_contact.provider.header_color(:hex)

    mail(to: @provider_contact.to, subject: "Contact from user on Chalkler, #{@provider_contact.subject}") do |format| 
      format.text { render layout: 'standard_mailer' }
      format.html { render layout: 'standard_mailer' }
    end
  end

end
