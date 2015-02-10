# encoding: UTF-8
class PartnerInquiryMailer < BaseChalkleMailer

  default from: '"chalkle°" <learn@chalkle.com>'

  def new_partner_inquiry(partner_inquiry, recipiant)
    @partner_inquiry = partner_inquiry
    mail(to: recipiant.email, subject: "New Partner inquiry on Chalkle") do |format| 
      format.html { render layout: 'standard_mailer' }
    end
  end

end
