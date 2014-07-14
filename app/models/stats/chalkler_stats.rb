class ChalklerStats < ChannelStats

  def new_chalklers
    channel.new_chalklers(start,end_time).count
  end

  def previous
    ChalklerStats.new(start - period, period, channel)
  end

  def percent_new_chalklers
    percentage_change(previous.new_chalklers, new_chalklers)
  end

  def percent_active
    if channel.chalklers.empty?
      return 0
    else
      return (100.0*active_chalklers / channel.all_chalklers(end_time).count)
    end
  end

  def attendee
    l = channel.course_ran(start,end_time)
    total = 0
    l.each do |course|
      total = total + course.attendance
    end
    return total
  end

  def percent_attendee
    percentage_change(previous.attendee, attendee)
  end

  def fill_fraction
    l = channel.course_ran(start,end_time)
    total = 0
    l.each do |course|
      if course.attendance > 0
        total = total + course.attendance.to_d / (course.max_attendee.present? ? course.max_attendee.to_d : course.attendance.to_d)
      end
    end
    if l.length > 0
      return total / l.length*100
    else
      return 0
    end
  end

  private

  def active_chalklers
    end_date = (end_time - 2.months).midnight
    channel.chalklers.joins{bookings.outer}.where{(bookings.created_at.gt end_date.utc) | (chalklers.created_at.gt end_date.utc)}.select("chalklers.id").count
  end

end
