#= require plugins/monthly_calendar_cell.js

class MonthlyCalendar
  constructor: (element) ->
    @elem = $(element)
    @elem.find('td').monthlyCalendarCell()
    @_attachHandlers()

  ## PRIVATE

  _attachHandlers: () ->
    @elem.on('cell_expanded', @_handleCellExpanded)

  _handleCellExpanded: (event, cell) =>
    @_collapseCellsExcept(cell)

  _collapseCellsExcept: (exception) ->
    @_openCellsExcept(exception).each (index, cell) ->
      cell.collapse()

  _openCellsExcept: (exception) ->
    @_openCells().filter (index, cell) ->
      cell != exception

  _openCells: () ->
    @elem.find('td.expanded').map (index, element) ->
      $(element).data('monthlyCalendarCell')


$.fn.monthlyCalendar = (options) ->
  @each ->
    element = $(this)
    dataName = 'monthlyCalendar'

    return if element.data(dataName)
    element.data dataName, new MonthlyCalendar(this)
