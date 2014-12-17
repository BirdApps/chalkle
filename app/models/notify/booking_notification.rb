class Notify::BookingNotification < Notify::Notifier

  include Rails.application.routes.url_helpers
  
  def initialize(booking, role = NotificationPreference::CHALKLER)
    @booking = booking
    @role = role
  end

  def confirmation
    #for chalkler
    message = I18n.t('notify.booking.confirmation.to_chalkler', course_name: booking.course.name)
    booking.chalkler.send_notification Notification::REMINDER, course_path(booking.course), message, booking
    BookingMailer.booking_confirmation_to_chalkler(booking).deliver!

    #for teacher
    message = I18n.t('notify.booking.confirmation.to_teacher', course_name: booking.course.name)
    booking.teacher.chalkler.send_notification Notification::REMINDER, course_path(booking.course), message, booking
    BookingMailer.booking_confirmation_to_teacher(booking).deliver!
  end

  def reminder
    message = I18n.t('notify.booking.reminder', course_name: booking.course.name)
      
    chalkler.send_notification Notification::REMINDER, course_path(booking.course), message, booking

    BookingMailer.booking_reminder(booking).deliver!
  end

  def completed
    message = I18n.t('notify.booking.completed', course_name: booking.course.name)

    chalkler.send_notification Notification::REMINDER, course_path(booking.course), message, booking

    BookingMailer.booking_completed(booking).deliver!
  end

  def cancelled
    refund_text = booking.pending_refund? ? t('notify.booking.refund') : ""

    message = I18n.t('notify.booking.cancelled.to_chalkler', course_name: booking.course.name, refund: refund_text)

    chalkler.send_notification Notification::REMINDER, course_path(booking.course), message, booking

    BookingMailer.booking_cancelled_for_chalkler(booking).deliver!
  end

  private
    def booking
      @booking
    end

end