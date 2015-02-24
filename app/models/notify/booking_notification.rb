class Notify::BookingNotification < Notify::Notifier
  
  def initialize(booking, role = NotificationPreference::CHALKLER)
    @booking = booking
    @role = role
  end

  def confirmation
    #to chalkler
    if booking.payment.present?
      PaymentMailer.receipt_to_chalkler(booking.payment).deliver!
    end

    message = I18n.t('notify.booking.confirmation.to_chalkler', course_name: booking.course.name)
    booking.chalkler.send_notification Notification::REMINDER, course_path(booking.course), message, booking

    if booking.chalkler.email_about? :booking_confirmation_to_chalkler
      BookingMailer.booking_confirmation_to_chalkler(booking).deliver!  
    end

    #to teacher
    message = I18n.t('notify.booking.confirmation.to_teacher', course_name: booking.course.name, from_name: booking.name)

    booking.teacher.chalkler.send_notification(Notification::REMINDER, course_path(booking.course), message, booking) if booking.teacher.chalkler

    if booking.teacher.chalkler.blank? || booking.teacher.chalkler.email_about?(:booking_confirmation_to_teacher)
      BookingMailer.booking_confirmation_to_teacher(booking).deliver!
    end
  
  end

  def reminder
    message = I18n.t('notify.booking.reminder', course_name: booking.course.name)
      
    booking.chalkler.send_notification Notification::REMINDER, course_path(booking.course), message, booking

    BookingMailer.booking_reminder(booking).deliver! if booking.chalkler.email_about?(:booking_reminder)

  end

  #booked_in and booked_in_with_invite notificaiton for non chalklers
  def booked_in
    message = I18n.t('notify.booking.booked_in', course_name: booking.course.name, booker: booking.booker.name)
    BookingMailer.booking_confirmation_to_non_chalkler(booking).deliver! 
  end

  def completed
    message = I18n.t('notify.booking.completed', course_name: booking.course.name)

    booking.chalkler.send_notification Notification::REMINDER, course_path(booking.course), message, booking

    BookingMailer.booking_completed(booking).deliver! if booking.chalkler.email_about? :booking_completed
  end

  def cancelled
    #to chalkler
    refund_text = booking.pending_refund? ? I18n.t('notify.booking.refund') : ""
    message = I18n.t('notify.booking.cancelled.to_chalkler', course_name: booking.course.name, refund: refund_text)
    booking.chalkler.send_notification Notification::REMINDER, course_path(booking.course), message, booking

    if booking.chalkler.email_about? :booking_cancelled_to_chalkler 
      BookingMailer.booking_cancelled_to_chalkler(booking).deliver!
    end

    if role == :chalkler
      #to teacher
      message = I18n.t('notify.booking.cancelled.to_teacher', course_name: booking.course.name, from_name: booking.name)

      booking.teacher.chalkler.send_notification(Notification::REMINDER, course_path(booking.course), message, booking) if booking.teacher.chalkler

      #always send notificaitons to pseudo teachers, otherwise check notification prefs
      if booking.teacher.chalkler.blank? || booking.teacher.chalkler.email_about?(:booking_cancelled_to_teacher)
        BookingMailer.booking_cancelled_to_teacher(booking).deliver!
      end
    end


    if role == :chalkler or :teacher
      #to channel admin
      message = I18n.t('notify.booking.cancelled.to_channel_admin', course_name: booking.course.name, from_name: booking.name)

      booking.channel.channel_admins.map(&:chalkler).each do |channel_admin|
        channel_admin.send_notification(Notification::REMINDER, course_path(booking.course), message, booking)
        if channel_admin != booking.teacher.chalkler && channel_admin.email_about?(:booking_cancelled_to_provider)
          BookingMailer.booking_cancelled_to_channel_admin(booking, channel_admin).deliver!
        end

      end
    end
  end

  private
    def booking
      @booking
    end

end