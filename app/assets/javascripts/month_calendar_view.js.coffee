#= require plugins/monthly_calendar.js

$(document).ready ->
  $('table.month_calendar_view').monthlyCalendar()

  $(document).on "ajax:success", '[data-append]', (evt, data, status, xhr) ->
    target_id = $(this).attr('data-append')
    $("##{target_id}").append(data)
