class Notify::OutgoingPaymentNotification < Notify::Notifier
  
  def initialize(outgoing_payment, role = NotificationPreference::SUPER)
    @outgoing_payment = outgoing_payment
    @role = role
  end

  def paid
    if @outgoing_payment.for_provider? 
      
      message = I18n.t('notify.outgoing_payment.paid_provider', payment_total: sprintf('%.2f',@outgoing_payment.total), provider_name: @outgoing_payment.outgoing_provider.name )
      link = provider_outgoing_path(@outgoing_payment.path_params)
      
      @outgoing_payment.recipient.provider_admins.each do |admin|
        if admin.chalkler.present?
          @chalkler = admin.chalkler
          admin.chalkler.send_notification(Notification::CHALKLE, link, message, @outgoing_payment)
        end
      end

    else
     
      message = I18n.t('notify.outgoing_payment.paid_teacher', payment_total: sprintf('%.2f',@outgoing_payment.total), provider_name: @outgoing_payment.outgoing_provider.name )
      link = provider_teacher_outgoing_path(@outgoing_payment.path_params)
      
      if @outgoing_payment.recipient.chalkler.present?
        @chalkler = @outgoing_payment.recipient.chalkler
        @outgoing_payment.recipient.send_notification(Notification::CHALKLE, link, message, @outgoing_payment)
      end

    end

    OutgoingPaymentMailer.remittance_advice(@outgoing_payment).deliver!
  end
end