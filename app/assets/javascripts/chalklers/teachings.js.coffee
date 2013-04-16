$("#teaching_teacher_cost").keyup (e) ->
  if (parseFloat(e.target.value) > 0) && $("#teaching_channel_select").val()
    TeacherPercent = parseFloat(teacher_percentages[$("#teaching_channel_select").val() - 1])
    ChannelPercent = parseFloat(channel_percentages[$("#teaching_channel_select").val() - 1])
    ChalklePercent = parseFloat( 1 - TeacherPercent - ChannelPercent )
    Total = FinalPrice(parseFloat(e.target.value), TeacherPercent, ChalklePercent, ChannelPercent)
    $("#teaching_price").val Math.ceil(Total)
  else if $("#teaching_channel_select").val() is ""
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
    