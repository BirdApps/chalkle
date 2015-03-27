class Notify::BookingSetNotification < Notify::Notifier
  
  def initialize(booking_set, role = NotificationPreference::CHALKLER)
    @booking_set = booking_set
    @role = role
  end


  def send_recipt(booking_set)
    #to booker
    booking_set.payments.each do |payment|
      PaymentMailer.receipt_to_chalkler(payment).deliver!
    end
  end


  def declined
    message = I18n.t('notify.booking_set.declined', course_name: @booking_set.course.name)
    @booking_set.booker.send_notification Notification::REMINDER, declined_provider_course_bookings_path( @booking_set.course.path_params({ booking_ids: @booking_set.id }) ), message, @booking_set.course
  end

end