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

  def attendee_table(last_day, period, num_rows)
  attendee = []
  (0..(num_rows-1)).each do |i|
    attendee[i] = chalkler_stats(last_day.weeks_ago(i+1),period).attendee
  end
  attendee
  end

  def fill_fraction_table(last_day, period, num_rows)
  fill_fraction = []
  (0..(num_rows-1)).each do |i|
    fill_fraction[i] = chalkler_stats(last_day.weeks_ago(i+1),period).fill_fraction
  end
  fill_fraction
  end

  def new_chalklers_table(last_day, period, num_rows)
  new_chalklers = []
  (0..(num_rows-1)).each do |i|
    new_chalklers[i] = chalkler_stats(last_day.weeks_ago(i+1),period).new_chalklers
  end
  new_chalklers
  end

  def percent_active_table(last_day, period, num_rows)
  percent_active = []
  (0..(num_rows-1)).each do |i|
    percent_active[i] = chalkler_stats(last_day.weeks_ago(i+1),period).percent_active
  end
  percent_active
  end

end