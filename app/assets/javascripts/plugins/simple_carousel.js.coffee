
class SimpleCarousel
  constructor: (element) ->
    @elem = $(element)
    @_setupNav()

  handleNavClick: (event) =>
    if event.data == 'left'
      @left()
    if event.data == 'right'
      @right()
    event.stopPropagation()
    false

  left: ->
    alert 'left'

  right: ->
    alert 'right'

  ## PRIVATE

  _setupNav: () ->
    @elem.find('.nav_left').on 'click', null, 'left', @handleNavClick
    @elem.find('.nav_right').on 'click', null, 'right', @handleNavClick

$.fn.simpleCarousel = (options) ->
  @each ->
    element = $(this)
    dataName = 'simpleCarousel'

    return if element.data(dataName)
    element.data dataName, new SimpleCarousel(this)
