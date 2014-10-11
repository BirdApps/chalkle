# encoding: UTF-8
class ChannelMailer < BaseChalkleMailer

  default from: '"chalkle°" <learn@chalkle.com>'

  def contact(channel_contact)
    @channel_contact = channel_contact
    mail(to: @channel_contact.to, subject: "Contact from user on Chalkler, #{@channel_contact.subject}") do |format| 
      format.text { render layout: 'standard_mailer' }
      format.html { render layout: 'standard_mailer' }
    end
  end

end
