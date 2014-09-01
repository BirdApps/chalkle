# encoding: utf-8

module CourseHelper
	def may_cancel_email(name,min_attendee)
    URI.escape("

Thank you for signing up to the upcoming chalkle class ") + URI.escape(name.gsub(/&/,"and")) + URI.escape(". We are writing to tell you that a minimum number of ") + (min_attendee.present? ? min_attendee : 2).to_s + URI.escape(" people is required for this class to go ahead.

If it is cancelled, you will receive a notice from Meetup upon cancellation and we will try to schedule the class for another date.

Your Chalkle Administrator")
  end

  def pretty_duration(course)
    # when above 24 this should cover periods greater than a day in a more elegent way than n hours  - Josh
     (course.duration.to_i/60/60).to_s+" hours"
  end

  def pretty_time(date)
    date.strftime("%l:%M%P")
  end

  def pretty_time_range(start, finish)
    return unless start && finish
    if(finish - start < 24*3600)
      pretty_time(start)+" -"+pretty_time(finish)
    else
      day_ordinal_month(start)+" "+pretty_time(start)+" "+day_ordinal_month(finish)+" "+pretty_time(finish)
    end
  end

  def day_ordinal_month(date, use_relative_day = true)
    return unless date
    relative = relative_day_name date.to_date
    return relative if relative && use_relative_day
    ordinalDay = date.day.ordinalize
    date.strftime("%B #{ordinalDay}, %Y")
  end

  def relative_month_name(month)
    relative_time_name month, Month.current, 'Month'
  end

  def relative_week_name(week)
    relative_time_name week, Week.current, 'Week'
  end

  def relative_time_name(time, current, time_name)
    return "Last #{time_name}" if time == current.previous
    return "This #{time_name}" if time == current
    return "Next #{time_name}" if time == current.next
    nil
  end

  def relative_day_title(day)
    relative_name = relative_day_name(day)

    parts = [day_title(day)]
    parts << content_tag(:span, ' / ' + relative_name, class: 'relative_name') if relative_name
    parts.join('').html_safe
  end

  def relative_date_class(date, current = Date.today)
    return "past" if date < current
    return "present" if date == current
    "future"
  end

  def relative_day_name(day, current = Date.today)
    return "Yesterday" if day == current - 1
    return "Today" if day == current
    return "Tomorrow" if day == current + 1
    nil
  end

  def month_title(month)
    parts = [month.name]
    parts << month.year if month.year != Month.current.year
    parts.join ' '
  end

  def week_title(week)
    date_range_title(week)
  end

  def date_range_title(date_range)
    [date_title(date_range.first), date_title(date_range.last)].join(' - ').html_safe
  end

  def day_title(date)
    l date, format: :weekday
  end

  def date_title(date)
    date.to_s(:short).strip.gsub(' ', '&nbsp;').html_safe
  end

  def path_for_course(course)
    if (@channel || course.channel)
      channel_course_url(@channel || course.channel, course)
    end
  end

  def course_classes(course, base_class = 'course')
    results = [base_class]
    results << (course.course_upload_image.present? ? 'has-image' : 'no-image')
    results << "category#{course.best_colour_num}" if course.best_colour_num
    results << 'active' if @course && @course == course
    results
  end

  def course_availability(course)
    if course.limited_spaces?
      if course.spaces_left?
        pluralize(course.spaces_left, 'spot') + ' left'
      else
        'Fully booked'
      end
    else
      'No booking limit'
    end
  end

  def course_call_to_action(course)
    availability = course_availability course
    if availability == 'No booking limit'
      availability = 'Join'
    end
    availability
  end

  def course_attendance(course)
    ""
  end

  def icon(name)
    content_tag(:i, nil, class: "fa fa-#{name.to_s.gsub('_', '-')}") + ' '
  end

  def course_index_welcome_message
    if @region
      if chalkler_signed_in?
        "Welcome to chalkle° in #{@region.name} #{current_chalkler.name}"
      else
        "Welcome to chalkle° in #{@region.name}"
      end
    elsif @channel
      if chalkler_signed_in?
        "Welcome to chalkle° in #{@channel.name} #{current_chalkler.name}"
      else
        "Welcome to chalkle° in #{@channel.name}"
      end
    else
      if chalkler_signed_in?
        "Welcome #{current_chalkler.name}, try these upcoming chalkles"
      else
        "Welcome, try these upcoming chalkles"
      end
    end
  end
end