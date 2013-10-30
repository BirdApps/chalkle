
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
    @_switchActive active, target

  right: ->
    active = @getActive()
    target = active.next()
    @_switchActive active, target

  getActive: ->
    @elem.find('.page.active')

  ## PRIVATE

  _switchActive: (current, target) ->
    if target.length > 0
      current.removeClass 'active'
      @_setActive target

  _setActive: (target) ->
    if target.length > 0
      target.addClass 'active'
      @_setLinkStatus @_navLeft(), target.prev().length > 0
      @_setLinkStatus @_navRight(), target.next().length > 0


  _setLinkStatus: (nav, active) ->
    if active
      nav.removeClass 'disabled'
    else
      nav.addClass 'disabled'

  _setupNav: () ->
    @_navLeft().on 'click', null, 'left', @handleNavClick
    @_navRight().on 'click', null, 'right', @handleNavClick
    @_setActive @getActive()

  _navLeft: ->
    @elem.find('.nav_left')

  _navRight: ->
    @elem.find('.nav_right')

$.fn.simpleCarousel = (options) ->
  @each ->
    element = $(this)
    dataName = 'simpleCarousel'

    return if element.data(dataName)
    element.data dataName, new SimpleCarousel(this)
