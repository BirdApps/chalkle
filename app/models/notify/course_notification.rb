class Notify::CourseNotification < Notify::Notifier
  
  def initialize(course, role = NotificationPreference::CHALKLER)
    @course = course
    @role = role
  end
  
  def cancelled
    message = I18n.t('notify.booking.reminder', course_name: booking.course.name)
      
    course.bookings.confirmed.each do |booking|
      Notify.for(booking).as(:teacher).cancelled
    end

    CourseMailer.cancelled(course).deliver!
  end

  private
    def course
      @course
    end

end
