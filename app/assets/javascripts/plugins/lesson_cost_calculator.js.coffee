class LessonCostCalculator
  constructor: (element) ->
    @elem = $(element)
    @fields = {
      teacher_cost: @elem.find('#lesson_teacher_cost')
      cost:         @elem.find('#lesson_cost')
    }
    @_attachHandlers()

  triggerRecompute: =>
    $.ajax {
      url: '/classes/calculate_cost.json',
      data: {lesson: @_sourceData()},
      success: @onRecomputeSuccess,
      error: @onRecomputeError
    }

  ### HANDLERS ###

  onRecomputeSuccess: (data, textStatus) =>
    @_setData(data)

  onRecomputeError: (data, textStatus) =>
    alert "error: #{textStatus}, #{JSON.stringify(data)}"

  ### PRIVATE ###

  _setData: (values) ->
    @fields.cost.attr('value', values.cost)

  _sourceData: ->
    {
      teacher_cost: @fields.teacher_cost.attr('value')
    }

  _attachHandlers: ->
    @fields.teacher_cost.on 'change', @triggerRecompute


$.fn.lessonCostCalculator = (options) ->
  @each ->
    element = $(this)
    dataName = 'lessonCostCalculator'

    return if element.data(dataName)
    element.data dataName, new LessonCostCalculator(this)
