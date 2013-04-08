class ChannelDecorator < Draper::Decorator
  delegate_all

  def dates_table(first_day, period, num_rows)
    dates = []
    num_rows.times do |i|
      dates[i] = (first_day + i*period)
    end
    dates
  end

  def financial_table(first_day, period, num_rows)
    financials = []
    num_rows.times do |i|
      financials[i] = financial_stats(first_day + i*period, period)
    end
    financials
  end

  def lessons_table(first_day, period, num_rows)
    lessons = []
    num_rows.times do |i|
      lessons[i] = lesson_stats(first_day + i*period, period)
    end
    lessons
  end

  def chalkler_table(first_day, period, num_rows)
    chalkler = []
    num_rows.times do |i|
      chalkler[i] = chalkler_stats(first_day + i*period, period)
    end
    chalkler
  end

end