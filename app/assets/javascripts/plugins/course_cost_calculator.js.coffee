class LessonCostCalculator
  constructor: (element, options = {}) ->
    @elem = $(element)
    @resource_name = options.resource_name || 'course'
    @input_field_names = ['teacher_cost', 'material_cost', 'channel_id', 'channel_rate_override', 'course_class_type', 'fixed_overhead_cost', 'venue_cost','min_attendee','max_attendee']
    @fields = {
      teacher_cost:          @elem.find("##{@resource_name}_teacher_cost"),
      material_cost:         @elem.find("##{@resource_name}_material_cost"),
      venue_cost:            @elem.find("##{@resource_name}_venue_cost"),
      channel_id:            @elem.find("##{@resource_name}_channel_id"),
      cost:                  @elem.find("##{@resource_name}_cost"),
      fixed_cost:            @elem.find("##{@resource_name}_fixed_cost"),
      channel_rate_override: @elem.find("##{@resource_name}_channel_rate_override"),
      channel_fee:           @elem.find("##{@resource_name}_channel_fee"),
      chalkle_fee:           @elem.find("##{@resource_name}_chalkle_fee"),
      processing_fee:        @elem.find("##{@resource_name}_processing_fee"),
      course_class_type:     @elem.find("##{@resource_name}_course_class_type"), 
      fixed_overhead_cost:   @elem.find("##{@resource_name}_fixed_overhead_cost"),
      max_attendee:          @elem.find("##{@resource_name}_max_attendee"),
      min_attendee:          @elem.find("##{@resource_name}_min_attendee"),
      max_income:            @elem.find("##{@resource_name}_max_income"),
      min_income:            @elem.find("##{@resource_name}_min_income"),
    }
    @_attachHandlers()

  triggerRecompute: =>
    $.ajax {
      url: '/classes/calculate_cost.json',
      data: {course: @_sourceData()},
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
    @fields.cost.attr('value', '$'+parseFloat(values.calculate_cost).toFixed(2)).highlight_input()
    @fields.fixed_cost.attr('value', '$'+parseFloat(values.fixed_costs).toFixed(2)).highlight_input()
    @fields.channel_fee.attr('value', parseFloat(values.channel_fee).toFixed(2)).highlight_input()
    @fields.chalkle_fee.attr('value', parseFloat(values.chalkle_fee).toFixed(2)).highlight_input()
    @fields.processing_fee.attr('value', parseFloat(values.processing_fee).toFixed(2)).highlight_input()
    @fields.min_income.attr('value', '$'+parseFloat(values.min_income).toFixed(2)).highlight_input()
    @fields.max_income.attr('value', '$'+parseFloat(values.max_income).toFixed(2)).highlight_input()

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


$.fn.courseCostCalculator = (options) ->
  @each ->
    element = $(this)
    dataName = 'courseCostCalculator'

    return if element.data(dataName)
    element.data dataName, new LessonCostCalculator(this, options)

$.fn.highlight_input = () ->
  if this.effect
    this.effect("highlight", {}, 1500);
