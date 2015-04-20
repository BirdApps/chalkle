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

      PartnerInquiryMailer.delay.new_partner_inquiry(@partner_inquiry, chalkler) if chalkler.email_about? :new_partner_inquiry
    end

  end

  def archived
    message = "Partner inquiry from #{@partner_inquiry.name} archived"

    chalklers_to_notify = Chalkler.super

    chalklers_to_notify.each do |chalkler|
      chalkler.send_notification Notification::MESSAGE, sudo_partner_inquiry_path(@partner_inquiry), message, @partner_inquiry

      PartnerInquiryMailer.delay.archived_partner_inquiry(@partner_inquiry, chalkler) if chalkler.email_about? :archive_partner_inquiry
    end

  end


end
