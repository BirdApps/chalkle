# encoding: utf-8

module CourseHelper

  def calendar_details(course)
    "#{course.do_during_class}
     - more information at #{tiny_course_url(course)}"
  end

  def pretty_duration(course)
    return unless course
    # when above 24 this should cover periods greater than a day in a more elegent way than n hours  - Josh
    duration = ""
    if course.duration.to_i/60 >= 60
     duration += (course.duration.to_i/60/60).to_s+" hrs "
    end
    duration += (course.duration.to_i/60%60).to_s+" mins" unless course.duration.to_i/60%60 == 0
  end

  def pretty_time(date)
    return unless date
    unless date.min == 0
      date.strftime("%l:%M%P")
    else
      date.strftime("%l%P")
    end
  end


  def pretty_time_range(start, finish, abbr = false, force_date = false)
    return unless start && finish
    if(finish - start < 24*3600 && !force_date)
      pretty_time(start)+" - "+pretty_time(finish)
    elsif abbr
      quick_date(start)+" - "+quick_date(finish)
    else
      day_ordinal_month(start)+" - "+day_ordinal_month(finish)
    end
  end

  def quick_date_time(date, use_relative_day = true, include_year = false)
    return unless date
    quick_date(date, use_relative_day, include_year)+" — "+pretty_time(date)
  end

  def quick_date(date, use_relative_day = true, include_year = false)
    return unless date
    relative = relative_day_name date.to_date
    if relative && use_relative_day
      relative
    else
      if include_year || date.year != DateTime.current.year
        date.strftime("%d %b, %y")
      else
        date.strftime("%d %b")
      end
    end
  end

  def day_ordinal_month(date, use_relative_day = true, include_year = false, include_wday = false, include_time = false)
    return unless date
    relative = relative_day_name date.to_date
    if relative && use_relative_day
      if include_time
        return relative + ", "+ pretty_time(date) 
      else
        return relative
      end
    end
    ordinalDay = date.day.ordinalize
    wday = include_wday ? date.strftime("%A, ") : ""
    if include_year || date.year != DateTime.current.year
      wday+date.strftime("%B #{ordinalDay}, %Y")
    else
      wday+date.strftime("%B #{ordinalDay}")
    end
  end

  def relative_month_name(month)
    return unless month
    relative_time_name month, Month.current, 'Month'
  end

  def relative_week_name(week)
     return unless week
    relative_time_name week, Week.current, 'Week'
  end

  def relative_time_name(time, current, time_name)
    return unless time && current && time_name
    return "Last #{time_name}" if time == current.previous
    return "This #{time_name}" if time == current
    return "Next #{time_name}" if time == current.next
    nil
  end

  def relative_day_title(day)
    return unless day
    relative_name = relative_day_name(day)

    parts = [day_title(day)]
    parts << content_tag(:span, ' / ' + relative_name, class: 'relative_name') if relative_name
    parts.join('').html_safe
  end

  def relative_day_name(day, current = Date.current)
    return "Yesterday" if day == current - 1
    return "Today" if day == current
    return "Tomorrow" if day == current + 1
    nil
  end

  def show_header?
    @show_header.nil? ? super : @show_header
  end

  def devise_mapping
    Devise.mappings[:chalkler]
  end

  def resource_name
    devise_mapping.name
  end

  def resource_class
    devise_mapping.to
  end

end