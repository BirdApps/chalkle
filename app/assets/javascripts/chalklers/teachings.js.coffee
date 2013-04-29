Price = set: (teacherCost, channelID, teacherPercentages, channelPercentages, channelIndex) ->
  channelIndex = channelIndex.indexOf(channelID)
  teacherPercent = parseFloat(teacherPercentages[channelIndex])
  channelPercent = parseFloat(channelPercentages[channelIndex])
  chalklePercent = parseFloat( 1 - teacherPercent - channelPercent )
  Total = finalPrice(parseFloat(teacherCost), teacherPercent, chalklePercent, channelPercent)
  return Total

$("#teaching_teacher_cost").keyup (e) ->
  if (parseFloat(e.target.value) > 0) && $("#teaching_channel_id").val()
    $("#teaching_price").val Math.ceil( Price.set e.target.value, $("#teaching_channel_id").val(), teacher_Percentages, channel_Percentages, channel_Index )
  else if $("#teaching_channel_id").val() is ""
    $("#teaching_price").val "Please select a channel"
  else
    $("#teaching_price").val 0.0

$("#teaching_channel_id").change (e) ->
  if (parseFloat($("#teaching_teacher_cost").val()) > 0) && e.target.value
    $("#teaching_price").val Math.ceil( Price.set $("#teaching_teacher_cost").val(), e.target.value, teacher_Percentages, channel_Percentages, channel_Index )
  else if e.target.value is ""
    $("#teaching_price").val "Please select a channel"
  else
    $("#teaching_price").val 0.0
