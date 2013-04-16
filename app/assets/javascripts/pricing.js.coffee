@Fee = (Teacher_cost, Teacher_percentage, Chalkle_percentage) ->
  if Teacher_percentage > 0
    Teacher_cost / Teacher_percentage * Chalkle_percentage
  else
    0

@AddGST = (Amount) ->
	Amount*1.15

@FinalPrice = (Teacher_cost, Teacher_percentage, Chalkle_percentage, Channel_percentage) ->
  ChalkleFee = Fee Teacher_cost, Teacher_percentage, Chalkle_percentage
  ChannelFee = Fee Teacher_cost, Teacher_percentage, Channel_percentage
  Teacher_cost + AddGST(ChalkleFee + ChannelFee)
    