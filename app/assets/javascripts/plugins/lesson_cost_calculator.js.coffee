class LessonCostCalculator
  constructor: (element, options = {}) ->
    @elem = $(element)
    @resource_name = options.resource_name || 'lesson'
    @input_field_names = ['teacher_cost', 'material_cost', 'channel_id', 'channel_rate_override']
    @fields = {
      teacher_cost:          @elem.find("##{@resource_name}_teacher_cost"),
      material_cost:         @elem.find("##{@resource_name}_material_cost"),
      channel_id:            @elem.find("##{@resource_name}_channel_id"),
      cost:                  @elem.find("##{@resource_name}_cost"),
      channel_rate_override: @elem.find("##{@resource_name}_channel_rate_override"),
      channel_fee:           @elem.find("##{@resource_name}_channel_fee"),
      chalkle_fee:           @elem.find("##{@resource_name}_chalkle_fee"),
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
    @fields.cost.attr('value', values.cost).highlight_input()
    @fields.channel_fee.attr('value', values.channel_fee).highlight_input()
    @fields.chalkle_fee.attr('value', values.chalkle_fee).highlight_input()

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
    element.data dataName, new LessonCostCalculator(this, options)

$.fn.highlight_input = () ->
  if this.effect
    this.effect("highlight", {}, 1500);
