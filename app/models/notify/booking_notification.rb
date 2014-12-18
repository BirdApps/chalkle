class Notify::BookingNotification < Notify::Notifier
  
  def initialize(booking, role = NotificationPreference::CHALKLER)
    @booking = booking
    @role = role
  end

  def confirmation
    #to chalkler
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

  def completed
    message = I18n.t('notify.booking.completed', course_name: booking.course.name)

    booking.chalkler.send_notification Notification::REMINDER, course_path(booking.course), message, booking

    BookingMailer.booking_completed(booking).deliver! if booking.chalkler.email_about? :booking_completed
  end

  def cancelled
    #to chalkler
    refund_text = booking.pending_refund? ? t('notify.booking.refund') : ""
    message = I18n.t('notify.booking.cancelled.to_chalkler', course_name: booking.course.name, refund: refund_text)
    booking.chalkler.send_notification Notification::REMINDER, course_path(booking.course), message, booking

    if booking.chalkler.email_about? :booking_cancelled_to_chalkler 
      BookingMailer.booking_cancelled_to_chalkler(booking).deliver!
    end

    if role == :chalkler
      #to teacher
      message = I18n.t('notify.booking.cancelled.to_teacher', course_name: booking.course.name, from_name: booking.name)

      booking.teacher.chalkler.send_notification(Notification::REMINDER, course_path(booking.course), message, booking) if booking.teacher.chalkler

      if booking.teacher.chalkler.blank? || booking.teacher.chalkler.email_about?(:booking_cancelled_to_teacher)
        BookingMailer.booking_cancelled_to_teacher(booking).deliver!
      end
    end
  end

  private
    def booking
      @booking
    end

end