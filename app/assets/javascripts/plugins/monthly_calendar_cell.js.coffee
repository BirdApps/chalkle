class MonthlyCalendarCell
  constructor: (element) ->
    @elem = $(element)
    @active_cell = null
    @_attachHandlers()
    @_updateCount()

  isExpanded: ->
    @elem.hasClass('expanded')

  hasContents: ->
    @_lessonCount() > 0

  canExpand: ->
    !@isExpanded() and @hasContents()

  collapse: ->
    @elem.removeClass('expanded')

  expand: ->
    @elem.closest('table').trigger('cell_expanded', this)
    if @canExpand()
      @elem.addClass('expanded')

  ## PRIVATE

  _attachHandlers: () ->
    @elem.on 'click', @_handleClick

  _handleClick: (event) =>
    unless @_elementInsideClassList(event.target)
      if @isExpanded()
        @collapse()
      else
        @expand()

  _elementInsideClassList: (element) ->
    @elem.find('ul.lessons').find(element).length > 0

  _lessonCount: ->
    @elem.find('ul li').length

  _updateCount: ->
    more_count = @_lessonCount() - 2
    if more_count > 1
      @elem.addClass('show_more')
      @elem.find('.lesson_count .number').text(more_count)
      @elem.find('li.viewable').last().addClass('last_showing')
    else
      @elem.removeClass('show_more')
      @elem.find('li').removeClass('last_showing')


$.fn.monthlyCalendarCell = (options) ->
  @each ->
    element = $(this)
    dataName = 'monthlyCalendarCell'

    return if element.data(dataName)
    element.data dataName, new MonthlyCalendarCell(this)
