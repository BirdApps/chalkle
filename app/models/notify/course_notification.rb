class Notify::CourseNotification < Notify::Notifier
  
  def initialize(course, role = NotificationPreference::CHALKLER)
    @course = course
    @role = role
  end

  def completed
    course.bookings.confirmed.each do |booking|
      Notify.for(booking).completed
    end
  end

  def cancelled
    
    cancelled_by = if current_user && current_user != course.teacher.chalkler
      I18n.t('notify.course.cancelled.by', name_who_cancelled: current_user.name)
    else
      ""
    end

    message = I18n.t('notify.course.cancelled.to_teacher', course_name: course.name)+ cancelled_by
      
    course.teacher.send_notification Notification::REMINDER, provider_course_path(course), message, course

    course.bookings.confirmed.each do |booking|
      Notify.for(booking).as(:teacher).cancelled
    end

    CourseMailer.cancelled_to_teacher(course).deliver!
  end

  private
    def course
      @course
    end

end
