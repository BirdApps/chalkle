#= require jquery-dotdotdot/jquery.dotdotdot.js
#= require plugins/lesson_calendar_cell.js

$(document).ready ->
  $(".ellipsis").dotdotdot()
  $('.month_calendar_view td').lessonCalendarCell()

