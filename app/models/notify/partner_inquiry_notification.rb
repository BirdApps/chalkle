class Notify::PartnerInquiryNotification < Notify::Notifier
  
  def initialize(partner_inquiry, role = NotificationPreference::CHALKLER)
    @partner_inquiry = partner_inquiry
    @role = role
  end
  
  def created
    message = "New partner inquiry from #{@partner_inquiry.name}"

    chalklers_to_notify = Chalkler.super

    chalklers_to_notify.each do |chalkler|
      chalkler.send_notification Notification::MESSAGE, sudo_partner_inquiry_path(@partner_inquiry), message, @partner_inquiry

      PartnerInquiryMailer.new_partner_inquiry(@partner_inquiry, chalkler).deliver! if chalkler.email_about? :new_partner_inquiry
    end

  end



end
