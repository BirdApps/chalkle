class Notify::BookingNotification < Notify::Notifier
  
  def initialize(booking, role = NotificationPreference::CHALKLER)
    @booking = booking
    @role = role
  end


  def reminder
    message = I18n.t('notify.booking.reminder', course_name: booking.course.name)
      
    booking.chalkler.send_notification Notification::REMINDER, provider_course_path(booking.course.path_params), message, booking

    BookingMailer.booking_reminder(booking).deliver! if booking.chalkler.email_about?(:booking_reminder)

  end

  #booked_in and booked_in_with_invite notificaiton for non chalklers
  def booked_in
    message = I18n.t('notify.booking.booked_in', course_name: booking.course.name, booker: booking.booker.name)
    BookingMailer.booking_confirmation_to_non_chalkler(booking).deliver!
    Chalkler.invite!({email: booking.pseudo_chalkler_email, name: booking.name}, booking.booker) if booking.invite_chalkler
  end

  def completed
    message = I18n.t('notify.booking.completed', course_name: booking.course.name)

    booking.chalkler.send_notification Notification::REMINDER, provider_course_path(booking.course.path_params), message, booking

    BookingMailer.booking_completed(booking).deliver! if booking.chalkler.email_about? :booking_completed
  end

  def cancelled
    #to chalkler
    refund_text = booking.pending_refund? ? I18n.t('notify.booking.refund') : ""
    message = I18n.t('notify.booking.cancelled.to_chalkler', course_name: booking.course.name, refund: refund_text)
    booking.chalkler.send_notification Notification::REMINDER, provider_course_path(booking.course.path_params), message, booking

    if booking.chalkler.email_about? :booking_cancelled_to_chalkler 
      BookingMailer.booking_cancelled_to_chalkler(booking).deliver!
    end

    if role == :chalkler
      #to teacher
      message = I18n.t('notify.booking.cancelled.to_teacher', course_name: booking.course.name, from_name: booking.name)

      booking.teacher.chalkler.send_notification(Notification::REMINDER, provider_course_path(booking.course.path_params), message, booking) if booking.teacher.chalkler

      #always send notificaitons to pseudo teachers, otherwise check notification prefs
      if booking.teacher.chalkler.blank? || booking.teacher.chalkler.email_about?(:booking_cancelled_to_teacher)
        BookingMailer.booking_cancelled_to_teacher(booking).deliver!
      end
    end


    if role == :chalkler or :teacher
      #to provider admin
      message = I18n.t('notify.booking.cancelled.to_provider_admin', course_name: booking.course.name, from_name: booking.name)

      booking.provider.provider_admins.map(&:chalkler).each do |provider_admin|
        provider_admin.send_notification(Notification::REMINDER, provider_course_path(booking.course.path_params), message, booking)
        if provider_admin != booking.teacher.chalkler && provider_admin.email_about?(:booking_cancelled_to_provider)
          BookingMailer.booking_cancelled_to_provider_admin(booking, provider_admin).deliver!
        end

      end
    end
  end

  private
    def booking
      @booking
    end

end