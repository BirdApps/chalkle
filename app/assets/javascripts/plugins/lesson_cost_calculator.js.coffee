class LessonCostCalculator
  constructor: (element) ->
    @elem = $(element)
    @input_field_names = ['teacher_cost', 'material_cost']
    @fields = {
      teacher_cost:  @elem.find('#lesson_teacher_cost'),
      material_cost: @elem.find('#lesson_material_cost'),
      cost:          @elem.find('#lesson_cost')
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
    result = {}
    for field_name in @input_field_names
      result[field_name] = @fields[field_name].attr('value')
    result

  _inputFields: ->
    @fields[field_name] for field_name in @input_field_names

  _attachHandlers: ->
    for field in @_inputFields()
      field.on 'change', @triggerRecompute


$.fn.lessonCostCalculator = (options) ->
  @each ->
    element = $(this)
    dataName = 'lessonCostCalculator'

    return if element.data(dataName)
    element.data dataName, new LessonCostCalculator(this)
