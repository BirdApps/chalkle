
Math.RandomInteger = (n) ->
  Math.floor(Math.random() * n);

class WeeklyCalendar
  constructor: (element) ->
    @elem = $(element)
    @_addSuggestClass()

  ## PRIVATE

  _addSuggestClass: ->
    day = @_bestSuggestClassDay()
    if day
      @_addSuggestClassToDay day

  _bestSuggestClassDay: ->
    days = @elem.find('.future')
    lowest_count = 100
    candidates = []
    days.each (index, day) =>
      count = $(day).find('.course').length
      if count > 0
        if count < lowest_count
          lowest_count = count
          candidates = []
        if count <= lowest_count
          candidates.push day
    return null if candidates.length == 0
    $(@_selectRandom(candidates))


  _selectRandom: (array) ->
    array[@_randomInteger(array.length)]

  _randomInteger: (max) ->
    Math.floor(Math.random() * max)

  _addSuggestClassToDay: ($day) ->
    link = "<a href=\"/chalklers/class_suggestions/new\">Click here to find out more</a>"
    $day.find('.courses').append("<div class=\"suggestion course_medium_container\">Your class here? #{link}</div>")

$.fn.weeklyCalendar = (options) ->
  @each ->
    element = $(this)
    dataName = 'weeklyCalendar'

    return if element.data(dataName)
    element.data dataName, new WeeklyCalendar(this)
