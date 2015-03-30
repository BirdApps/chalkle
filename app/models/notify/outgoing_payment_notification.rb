class Notify::OutgoingPaymentNotification < Notify::Notifier
  
  def initialize(outgoing_payment, role = NotificationPreference::SUPER)
    @outgoing_payment = outgoing_payment
    @role = role
  end

  def paid
    message = I18n.t('notify.outgoing_payment.paid', course_name: booking.course.name, booker: booking.booker.name)
    
    if @outgoing_payment.for_provider? 
      link = outgoings_provider_path(@outgoing_payment.recipient)
      @outgoing_payment.recipient.provider_admins.each do |admin|
        admin.chalkler.send_notification(Notification::CHALKLE, link, message, @outgoing_payment) if admin.chalkler.present?
      end
    else
      link = outgoings_provider_teacher_path(@outgoing_payment.recipient.path_params)
      @outgoing_payment.recipient.send_notification(Notification::CHALKLE, link, message, @outgoing_payment) if @outgoing_payment.recipient.chalkler.present?
    end

    OutgoingPaymentMailer.remittance_advice(@outgoing_payment).deliver!
  end

end