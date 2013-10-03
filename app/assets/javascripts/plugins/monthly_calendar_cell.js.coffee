#= require jquery-dotdotdot/jquery.dotdotdot.js

class MonthlyCalendarCell
  constructor: (element) ->
    @elem = $(element)
    @active_cell = null
    @_attachHandlers()
    $(".ellipsis").dotdotdot()
    @_updateCount()

  isExpanded: ->
    @elem.hasClass('expanded')

  hasContents: ->
    @_lessonCount() > 0

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

  _lessonCount: ->
    @elem.find('ul li').length

  _updateCount: ->
    more_count = @_lessonCount() - 2
    if more_count > 1
      @elem.addClass('show_more')
      @elem.find('.lesson_count .number').text(more_count)
    else
      @elem.removeClass('show_more')


$.fn.monthlyCalendarCell = (options) ->
  @each ->
    element = $(this)
    dataName = 'monthlyCalendarCell'

    return if element.data(dataName)
    element.data dataName, new MonthlyCalendarCell(this)
