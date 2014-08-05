class CourseStats < ChannelStats

  def previous
    CourseStats.new(start - period, period, channel)
  end

  def courses_announced
    channel.course_announced(start,end_time).count
  end

  def percent_courses_announced
    percentage_change(previous.courses_announced, courses_announced)
  end

  def new_courses_announced
    new_course(channel.course_announced(start,end_time))
  end

  def courses_ran
    channel.course_ran(start,end_time).count
  end

  def percent_courses_ran
    percentage_change(previous.courses_ran, courses_ran)
  end

  def new_courses_ran
    channel.course_ran(start,end_time).not_repeat_course.count
  end

  def cancelled_courses
    channel.cancel_courses(start,end_time).count
  end

  def percent_cancelled_courses
    percentage_change(previous.cancelled_courses, cancelled_courses)
  end

  def new_cancelled_courses
    channel.cancel_courses(start,end_time).not_repeat_course.count
  end

  def paid_courses
    channel.paid_courses(start,end_time).count
  end

  def percent_paid_courses
    percentage_change(previous.paid_courses, paid_courses)
  end

  private

  def new_course(courses)
    courses.not_repeat_course.count
  end

end
