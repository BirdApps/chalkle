#= require jquery-dotdotdot/jquery.dotdotdot.js

class MonthlyCalendarCell
  constructor: (element) ->
    @elem = $(element)
    @active_cell = null
    @_attachHandlers()
    $(".ellipsis").dotdotdot()

  isExpanded: () ->
    @elem.hasClass('expanded')

  collapse: () ->
    @elem.removeClass('expanded')

  expand: () ->
    @elem.addClass('expanded')
    @elem.closest('table').trigger('cell_expanded', this)

  ## PRIVATE

  _attachHandlers: () ->
    @elem.on 'click', @_handleClick

  _handleClick: (event) =>
    if @isExpanded()
      @collapse()
    else
      @expand()


$.fn.monthlyCalendarCell = (options) ->
  @each ->
    element = $(this)
    dataName = 'monthlyCalendarCell'

    return if element.data(dataName)
    element.data dataName, new MonthlyCalendarCell(this)
