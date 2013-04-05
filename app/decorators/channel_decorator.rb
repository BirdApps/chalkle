class ChannelDecorator < Draper::Decorator
  delegate_all

  def last_date
  	Date.today.end_of_week(start_day= :wednesday).midnight
  end

  def turnover_table(period, num_rows)
  turnover = []
  (0..(num_rows-1)).each do |i|
    turnover[i] = financial_stats(last_date.weeks_ago(i+1),period).turnover
 	end
 	turnover  
  end

  def cost_table(period, num_rows)
  cost = []
  (0..(num_rows-1)).each do |i|
    cost[i] = financial_stats(last_date.weeks_ago(i+1),period).cost
 	end
 	cost  
  end

  def percentage_change(input)
  output = []
  (1..(input.length - 1)).each do |i|
    output[i-1] = (input[i] > 0) ? (input[i-1].to_d / input[i] - 1)*100.0 : nil
  end
  output
  end

  def mean(input)
    input.reject! {|x| x.nil?}
    input.length > 0 ? input.sum / input.length : nil
  end

end