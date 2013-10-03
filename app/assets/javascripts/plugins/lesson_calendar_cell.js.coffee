class LessonCalendarCell
  constructor: (element, options) ->
    @elem = $(element)
    @settings = options or {}
    @_attachHandlers()

  ## PRIVATE

  _attachHandlers: () ->
    @elem.on 'click', @_handleClick

  _handleClick: (event) =>
    @elem.toggleClass('expanded')


$.fn.lessonCalendarCell = (options) ->
  @each ->
    element = $(this)
    dataName = 'lessonCalendarCell'

    return if element.data(dataName)
    element.data dataName, new LessonCalendarCell(this, options)
