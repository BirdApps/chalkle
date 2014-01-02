#= require plugins/monthly_calendar.js
#= require plugins/weekly_calendar.js

class LessonsIndex
  constructor: (element) ->
    @elem = $(element)
    @elem.find('table.month_calendar_view').monthlyCalendar()
    @elem.find('.week_calendar_view').weeklyCalendar()

  activeViewName: () ->
    @elem.find('.tab-content .active').attr('id')

$.fn.lessonsIndex = (options) ->
  @each ->
    element = $(this)
    dataName = 'lessonsIndex'

    return if element.data(dataName)
    element.data dataName, new LessonsIndex(this)
