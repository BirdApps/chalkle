# encoding: utf-8

module LessonHelper
	def may_cancel_email(name,min_attendee)
    URI.escape("

Thank you for signing up to the upcoming chalkle class ") + URI.escape(name.gsub(/&/,"and")) + URI.escape(". We are writing to tell you that a minimum number of ") + (min_attendee.present? ? min_attendee : 2).to_s + URI.escape(" people is required for this class to go ahead.

If it is cancelled, you will receive a notice from Meetup upon cancellation and we will try to schedule the class for another date.

Your Chalkle Administrator")
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

  def path_for_lesson(lesson)
    channel_lesson_url(@channel || lesson.channel, lesson)
  end

  def lesson_classes(lesson, base_class = 'lesson')
    results = [base_class]
    results << (lesson.lesson_upload_image.present? ? 'has-image' : 'no-image')
    results << "category#{lesson.best_colour_num}" if lesson.best_colour_num
    results << 'active' if @lesson && @lesson == lesson
    results
  end

  def lesson_availability(lesson)
    content_tag :div, nil, class: 'availability' do
      if lesson.limited_spaces?
        if lesson.spaces_left?
          icon(:check) + pluralize(lesson.spaces_left, 'spot') + ' left'
        else
          'fully booked!'
        end
      else
        icon(:check) + 'No size limit'
      end
    end
  end

  def lesson_attendance(lesson)
    ""
  end

  def icon(name)
    content_tag(:i, nil, class: "fa fa-#{name.to_s.gsub('_', '-')}") + ' '
  end

  def lesson_index_welcome_message
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