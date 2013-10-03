#= require jquery-dotdotdot/jquery.dotdotdot.js

class MonthlyCalendarCell
  constructor: (element) ->
    @elem = $(element)
    @active_cell = null
    @_attachHandlers()
    $(".ellipsis").dotdotdot()

  isExpanded: ->
    @elem.hasClass('expanded')

  hasContents: ->
    @elem.find('ul li').length > 0

  canExpand: ->
    !@isExpanded() and @hasContents()

  collapse: ->
    @elem.removeClass('expanded')
    @_updateEllipsis()

  expand: ->
    @elem.closest('table').trigger('cell_expanded', this)
    if @canExpand()
      @elem.addClass('expanded')
      @_updateEllipsis()

  ## PRIVATE

  _attachHandlers: () ->
    @elem.on 'click', @_handleClick

  _handleClick: (event) =>
    if @isExpanded()
      @collapse()
    else
      @expand()

  _updateEllipsis: ->
    @elem.find('.ellipsis').trigger('update');

$.fn.monthlyCalendarCell = (options) ->
  @each ->
    element = $(this)
    dataName = 'monthlyCalendarCell'

    return if element.data(dataName)
    element.data dataName, new MonthlyCalendarCell(this)
