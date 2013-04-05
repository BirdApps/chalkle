class ChannelDecorator < Draper::Decorator
  delegate_all

  def turnover_table(last_day, period, num_rows)
  turnover = []
  (0..(num_rows-1)).each do |i|
    turnover[i] = financial_stats(last_day.weeks_ago(i+1),period).turnover
 	end
 	turnover  
  end

  def cost_table(last_day, period, num_rows)
  cost = []
  (0..(num_rows-1)).each do |i|
    cost[i] = financial_stats(last_day.weeks_ago(i+1),period).cost
 	end
 	cost  
  end

end