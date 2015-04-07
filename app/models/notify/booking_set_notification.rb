class Notify::BookingSetNotification < Notify::Notifier
  
  def initialize(booking_set, role = NotificationPreference::CHALKLER)
    @booking_set = booking_set
    @role = role
  end


  def send_receipt
    #to booker
    @booking_set.payments.each do |payment|
      PaymentMailer.receipt_to_chalkler(payment).deliver!
    end
  end


  def declined
    message = I18n.t('notify.booking_set.declined', course_name: @booking_set.course.name)
    @booking_set.booker.send_notification Notification::REMINDER, declined_provider_course_bookings_path( @booking_set.course.path_params({ booking_ids: @booking_set.id }) ), message, @booking_set.course
  end



  def confirmation

    chalklers = @booking_set.bookings.collect(&:chalkler).uniq
    bookings_grouped_by_chalkler = Hash.new
    chalklers.each do |c|
      bookings_grouped_by_chalkler[c] = @booking_set.bookings.select{|b| b.chalkler == c }
    end
    
    
    if booking.pseudo_chalkler_email

      message = I18n.t('notify.booking.booked_in', course_name: booking.course.name, booker: booking.booker.name)
      BookingMailer.booking_confirmation_to_non_chalkler(booking).deliver!
      Chalkler.invite!({email: booking.pseudo_chalkler_email, name: booking.name}, booking.booker) if booking.invite_chalkler
    
    else

      message = I18n.t('notify.booking.confirmation.to_chalkler', course_name: booking.course.name)
      booking.chalkler.send_notification Notification::REMINDER, provider_course_path(booking.course.path_params), message, booking

      if booking.chalkler.email_about? :booking_confirmation_to_chalkler
        BookingMailer.booking_confirmation_to_chalkler(booking).deliver!  
      end
      
    end

    #to teacher
    message = I18n.t('notify.booking.confirmation.to_teacher', course_name: booking.course.name, from_name: booking.name)

    booking.teacher.chalkler.send_notification(Notification::REMINDER, provider_course_path(booking.course.path_params), message, booking) if booking.teacher.chalkler

    if booking.teacher.chalkler.blank? || booking.teacher.chalkler.email_about?(:booking_confirmation_to_teacher)
      BookingMailer.booking_confirmation_to_teacher(booking).deliver!
    end
  
  end

end