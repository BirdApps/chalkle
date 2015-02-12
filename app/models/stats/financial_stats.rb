class FinancialStats < ProviderStats

  attr_accessor :turnover, :percent_turnover, :cost, :percent_cost

  def turnover
    l = provider.course_ran(start, end_time)
    total = 0.0
    l.each do |course|
      total = course.collected_turnover + total
    end
    total
  end

  def cost
    l = provider.course_ran(start, end_time)
    total = 0.0
    l.each do |course|
      total = course.total_cost + total
    end
    total
  end

  def profit
    l = provider.course_ran(start, end_time)
    total = 0.0
    l.each do |course|
      total = course.income + total
    end
    total
  end

  def previous
    FinancialStats.new(start - period, period, provider)
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
