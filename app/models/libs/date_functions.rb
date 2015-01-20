module DateFunctions
  def self.pretty_duration(course)
    # when above 24 this should cover periods greater than a day in a more elegent way than n hours  - Josh
    duration = ""
    if course.duration.to_i/60 >= 60
     duration += (course.duration.to_i/60/60).to_s+" hrs "
    end
    duration += (course.duration.to_i/60%60).to_s+" mins" unless course.duration.to_i/60%60 == 0
    
  end

  def self.pretty_time(date)
    date.strftime("%l:%M%P")
  end


  def self.pretty_time_range(start, finish, abbr = false)
    return unless start && finish
    if(finish - start < 24*3600)
      pretty_time(start)+" - "+pretty_time(finish)
    elsif abbr
      quick_date(start)+" - "+quick_date(finish)
    else
      day_ordinal_month(start)+" - "+day_ordinal_month(finish)
    end
  end

  def self.quick_date_time(date, use_relative_day = true, include_year = false)
    return unless date
    quick_date(date, use_relative_day, include_year)+" — "+pretty_time(date)
  end

  def self.quick_date(date, use_relative_day = true, include_year = false)
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

  def self.day_ordinal_month(date, use_relative_day = true, include_year = false, include_wday = false)
    return unless date
    relative = relative_day_name date.to_date
    return relative if relative && use_relative_day
    ordinalDay = date.day.ordinalize
    wday = include_wday ? date.strftime("%A, ") : ""
    if include_year || date.year != DateTime.current.year
      wday+date.strftime("%B #{ordinalDay}, %y")
    else
      wday+date.strftime("%B #{ordinalDay}")
    end
  end

  def self.relative_month_name(month)
    relative_time_name month, Month.current, 'Month'
  end

  def self.relative_week_name(week)
    relative_time_name week, Week.current, 'Week'
  end

  def self.relative_time_name(time, current, time_name)
    return "Last #{time_name}" if time == current.previous
    return "This #{time_name}" if time == current
    return "Next #{time_name}" if time == current.next
    nil
  end

  def self.relative_day_title(day)
    relative_name = relative_day_name(day)

    parts = [day_title(day)]
    parts << content_tag(:span, ' / ' + relative_name, class: 'relative_name') if relative_name
    parts.join('').html_safe
  end

  def self.relative_date_class(date, current = Date.current)
    return "past" if date < current
    return "present" if date == current
    "future"
  end

  def self.relative_day_name(day, current = Date.current)
    return "Yesterday" if day == current - 1
    return "Today" if day == current
    return "Tomorrow" if day == current + 1
    nil
  end

  def self.month_title(month)
    parts = [month.name]
    parts << month.year if month.year != Month.current.year
    parts.join ' '
  end

  def self.week_title(week)
    date_range_title(week)
  end

  def self.date_range_title(date_range)
    [date_title(date_range.first), date_title(date_range.last)].join(' - ').html_safe
  end

  def self.day_title(date)
    l date, format: :weekday
  end

  def self.date_title(date)
    date.to_s(:short).strip.gsub(' ', '&nbsp;').html_safe
  end
end