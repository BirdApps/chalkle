class LessonStats < ChannelStats

  def lessons_ran
    channel.lesson_ran(start,end_time).count
  end

  def previous
    LessonStats.new(start - period, period, channel)
  end

  def percent_lessons_ran
    percentage_change(previous.lessons_ran, lessons_ran)
  end

  def new_lessons_ran
    new_lesson(channel.lesson_ran(start,end_time))
  end

  def cancelled_lessons
    channel.cancel_lessons(start,end_time).count
  end

  def percent_cancelled_lessons
    percentage_change(previous.cancelled_lessons, cancelled_lessons)
  end

  def new_cancelled_lessons
    new_lesson(channel.cancel_lessons(start,end_time))
  end

  def paid_lessons
    channel.paid_lessons(start,end_time).count
  end

  def percent_paid_lessons
    percentage_change(previous.paid_lessons, paid_lessons)
  end

  def attendee
    l = channel.lesson_ran(start,end_time)
    total = 0
    l.each do |lesson|
      total = total + lesson.attendance
    end
    return total
  end

  def percent_attendee
    percentage_change(previous.attendee, attendee)
  end

  def fill_fraction
    l = channel.lesson_ran(start,end_time)
    total = 0
    l.each do |lesson|
      if lesson.attendance > 0
        total = total + lesson.attendance.to_d / (lesson.max_attendee.present? ? lesson.max_attendee.to_d : lesson.attendance.to_d)
      end
    end
    if l.length > 0
      return total / l.length*100
    else
      return 0
    end
  end

  private

  def new_lesson(lessons)
    new_lesson = 0
    l_old = channel.past_lessons(start)
    lessons.each do |lesson|
    if l_old.find_by_name(lesson.name).nil?
      new_lesson = new_lesson + 1
    end
    end
    return new_lesson
  end

end
