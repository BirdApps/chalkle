#= require plugins/monthly_calendar.js
#= require plugins/weekly_calendar.js

class LessonsIndex
  constructor: (element) ->
    @elem = $(element)
    @elem.find('table.month_calendar_view').monthlyCalendar()
    @elem.find('.week_calendar_view').weeklyCalendar()
    @timer = null
    @_tabLinks().on 'shown.bs.tab', @onTabChanged

  activeViewName: () ->
    @elem.find('.tab-content .active').attr('id')

  ### HANDLERS ###

  onTabChanged: (event) =>
    if @timer
      window.clearTimeout @timer
    @timer = window.setTimeout @onTabChangeTimer, 1000

  onTabChangeTimer: =>
    $.ajax({
      type: "PUT",
      url: "/filters/update_view",
      data: {view: @activeViewName()}
    })

  ### PRIVATE ###

  _tabLinks: () ->
    @elem.find('a[data-toggle="tab"]')



$.fn.lessonsIndex = (options) ->
  @each ->
    element = $(this)
    dataName = 'lessonsIndex'

    return if element.data(dataName)
    element.data dataName, new LessonsIndex(this)
