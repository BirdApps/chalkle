#= require plugins/monthly_calendar.js
#= require plugins/weekly_calendar.js

$(document).ready ->
  $('table.month_calendar_view').monthlyCalendar()
  $('.week_calendar_view').weeklyCalendar()

  $(document).on "ajax:success", '[data-append]', (evt, data, status, xhr) ->
    target_id = $(this).attr('data-append')
    $("##{target_id}").append(data)

  $(document).on "ajax:before", '[data-remove-on-success]', (evt, data, status, xhr) ->
    $(this).addClass('ajax-sending');

  $(document).on "ajax:error", '[data-remove-on-success]', (evt, data, status, xhr) ->
    $(this).remove('ajax-error')

  $(document).on "ajax:success", '[data-remove-on-success]', (evt, data, status, xhr) ->
    $(this).remove()
