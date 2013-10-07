#= require plugins/monthly_calendar_cell.js

class MonthlyCalendar
  constructor: (element) ->
    @elem = $(element)
    @elem.find('td').monthlyCalendarCell()
    @_attachHandlers()
  $('[data-append]').on "ajax:success", (evt, data, status, xhr) ->
    target_id = $(this).attr('data-append')
    alert("appending to ##{target_id}")
    $("##{target_id}").append(data)

  ## PRIVATE

  _attachHandlers: () ->
    @elem.on('cell_expanded', @_handleCellExpanded)

  _handleCellExpanded: (event, cell) =>
    @_collapseCellsExcept(cell)

  _handleResized: (event) =>
    @elem.find('.ellipsis').trigger('update');

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
