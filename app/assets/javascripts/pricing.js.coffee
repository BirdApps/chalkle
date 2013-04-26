@fee = (teacherCost, teacherPercentage, chalklePercentage) ->
  if teacherPercentage > 0
    teacherCost / teacherPercentage * chalklePercentage
  else
    0

@addGST = (amount) ->
	amount*1.15

@finalPrice = (teacherCost, teacherPercentage, chalklePercentage, channelPercentage) ->
  chalkleFee = fee(teacherCost, teacherPercentage, chalklePercentage)
  channelFee = fee(teacherCost, teacherPercentage, channelPercentage)
  teacherCost + addGST(chalkleFee + channelFee)

    