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
    NewGSTPrice = Math.ceil 1.15*parseFloat($("#lesson_teacher_cost").val()) / (1 - ChannelPercentage.set(ChannelOverride) - ChalklePercentage.set(ChalkleOverride))
    NewPrice = NewGSTPrice/1.15
    $("#lesson_cost").val NewPrice.toFixed 2
    $("#lesson_gst_price").val NewGSTPrice
  else
    $("#lesson_cost").val "Missing teacher income per attendee"
    $("#lesson_gst_price").val "Missing teacher income per attendee"

$(document).keyup (e) ->
  Price.set $("#lesson_channel_percentage_override").val(), $("#lesson_chalkle_percentage_override").val()  if (e.target.id is "lesson_teacher_cost") or (e.target.id is "lesson_channel_percentage_override") or (e.target.id is "lesson_chalkle_percentage_override")

(($) ->
  $.fn.highlight = ->
    $(this).css
      color: "red"
      background: "yellow"

    $(this).fadeIn()
) jQuery