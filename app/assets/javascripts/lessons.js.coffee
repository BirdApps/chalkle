channelPercentage = set: (override) ->
  if override
    parseFloat(override) / 100
  else
    parseFloat default_channel_percentage

chalklePercentage = set: (override) ->
  if override
    parseFloat(override) / 100
  else
    parseFloat default_chalkle_percentage

Price = set: (channelOverride, chalkleOverride) ->
  if $("#lesson_teacher_cost").val()
    teacherCost = parseFloat( $("#lesson_teacher_cost").val() )
    chalklePercent = chalklePercentage.set(chalkleOverride)
    channelPercent = channelPercentage.set(channelOverride)
    teacherPercent = 1 - chalklePercent - channelPercent
    Total = finalPrice(teacherCost, teacherPercent, chalklePercent, channelPercent)
    $("#lesson_cost").val Math.ceil(Total)
  else
    $("#lesson_cost").val "Missing teacher income per attendee"


$(document).keyup (e) ->
  Price.set $("#lesson_channel_percentage_override").val(), $("#lesson_chalkle_percentage_override").val()  if (e.target.id is "lesson_teacher_cost") or (e.target.id is "lesson_channel_percentage_override") or (e.target.id is "lesson_chalkle_percentage_override")

(($) ->
  $.fn.highlight = ->
    $(this).css
      color: "red"
      background: "yellow"

    $(this).fadeIn()

) jQuery
