class ChannelDecorator < Draper::Decorator
  delegate_all

  def last_date
  	Date.today().end_of_week(start_day= :wednesday).to_date
  end

  def turnover_table(num_weeks)
  	turnover = []
  	(0..num_weeks).each do |i|
       turnover[i] = financial_stats(last_date.weeks_ago(i+1),1.week).turnover
 	end
 	return turnover  
  end

  def cost_table(num_weeks)
  	cost = []
  	(0..num_weeks).each do |i|
       cost[i] = financial_stats(last_date.weeks_ago(i+1),1.week).cost
 	end
 	return cost  
  end

  def percentage_change(input)
  	output = []
  	(1..(input.length - 1)).each do |i|
  	  output[i-1] = (input[i] > 0) ? (input[i-1].to_d / input[i] - 1)*100.0 : nil
  	end
  	return output
  end

end