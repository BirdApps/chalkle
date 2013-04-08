class FinancialStats < ChannelStats

  attr_accessor :turnover, :percent_turnover, :cost, :percent_cost

  def turnover
    l = channel.lesson_ran(start, end_time)
    total = 0.0
    l.each do |lesson|
      total = lesson.collected_revenue + total
    end
    total
  end

  def cost
    l = channel.lesson_ran(start, end_time)
    total = 0.0
    l.each do |lesson|
      total = lesson.total_cost + total
    end
    total
  end

  def profit
    turnover - cost
  end

  def previous
    FinancialStats.new(start - period, period, channel)
  end

  def percent_turnover
    percentage_change(previous.turnover, turnover)
  end

  def percent_cost
    percentage_change(previous.cost, cost)
  end
  
  def percent_profit
    percentage_change(previous.profit, profit)
  end

end
