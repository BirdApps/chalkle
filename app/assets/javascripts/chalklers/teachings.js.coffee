$("#teaching_teacher_cost").keyup (e) ->
  if (parseFloat(e.target.value) > 0) && $("#teaching_channel_id").val()
    ChannelIndex = channel_index.indexOf($("#teaching_channel_id").val())
    TeacherPercent = parseFloat(teacher_percentages[ChannelIndex])
    ChannelPercent = parseFloat(channel_percentages[ChannelIndex])
    ChalklePercent = parseFloat( 1 - TeacherPercent - ChannelPercent )
    Total = FinalPrice(parseFloat(e.target.value), TeacherPercent, ChalklePercent, ChannelPercent)
    $("#teaching_price").val Math.ceil(Total)
  else if $("#teaching_channel_id").val() is ""
    $("#teaching_price").val "Please select a channel"
  else
  	$("#teaching_price").val 0.0

(($) ->
  $.fn.highlight = ->
    $(this).css
      color: "red"
      background: "yellow"

    $(this).fadeIn()
) jQuery
    