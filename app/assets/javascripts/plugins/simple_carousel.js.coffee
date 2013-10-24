
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
    active = @getActive()
    target = active.prev()
    @_switchTarget active, target

  right: ->
    active = @getActive()
    target = active.next()
    @_switchTarget active, target

  getActive: ->
    @elem.find('.page.active')

  ## PRIVATE

  _switchTarget: (current, target) ->
    if target.length > 0
      current.removeClass 'active'
      target.addClass 'active'

  _setupNav: () ->
    @elem.find('.nav_left').on 'click', null, 'left', @handleNavClick
    @elem.find('.nav_right').on 'click', null, 'right', @handleNavClick

$.fn.simpleCarousel = (options) ->
  @each ->
    element = $(this)
    dataName = 'simpleCarousel'

    return if element.data(dataName)
    element.data dataName, new SimpleCarousel(this)
