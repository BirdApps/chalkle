ChannelPercentage = set: (override) ->
  if override
    parseFloat(override) / 100
  else
    parseFloat default_channel_percentage

ChalklePercentage = set: (override) ->
  if override
    parseFloat(override) / 100
  else
    parseFloat default_chalkle_percentage

Price = set: (ChannelOverride, ChalkleOverride) ->
  if $("#lesson_teacher_cost").val()
    Teacher_cost = parseFloat( $("#lesson_teacher_cost").val() )
    Chalkle_percent = ChalklePercentage.set(ChalkleOverride)
    Channel_percent = ChannelPercentage.set(ChannelOverride)
    Teacher_percent = 1 - Chalkle_percent - Channel_percent
    Total = FinalPrice(Teacher_cost, Teacher_percent, Chalkle_percent, Channel_percent)
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