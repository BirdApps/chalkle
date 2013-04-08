class ChannelDecorator < Draper::Decorator
  delegate_all

  def financial_table(first_day, period, num_rows)
    financials = StatsMath.new()
    num_rows.times do |i|
      financials[i] = channel_stats(first_day + i*period, period).financial_stats
    end
    financials
  end

  def lessons_table(first_day, period, num_rows)
    lessons = StatsMath.new()
    num_rows.times do |i|
      lessons[i] = channel_stats(first_day + i*period, period).lesson_stats
    end
    lessons
  end

  def chalkler_table(first_day, period, num_rows)
    chalkler = StatsMath.new()
    num_rows.times do |i|
      chalkler[i] = channel_stats(first_day + i*period, period).chalkler_stats
    end
    chalkler
  end

end