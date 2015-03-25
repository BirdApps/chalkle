class LessonCostCalculator
  constructor: (element, options = {}) ->
    @elem = $(element)
    @resource_name = options.resource_name || 'course'
    @input_field_names = ['teacher_cost','cost','provider_id', 'course_class_type','min_attendee','max_attendee','teacher_pay_type']
    @fields = {
      teacher_cost:          @elem.find("##{@resource_name}_teacher_cost"),
      provider_id:            @elem.find("##{@resource_name}_provider_id"),
      cost:                  @elem.find("##{@resource_name}_cost"),
      provider_fee:           @elem.find("##{@resource_name}_provider_fee"),
      chalkle_fee:           @elem.find("##{@resource_name}_chalkle_fee"),
      processing_fee:        @elem.find("##{@resource_name}_processing_fee"),
      course_class_type:     @elem.find("##{@resource_name}_course_class_type"), 
      max_attendee:          @elem.find("##{@resource_name}_max_attendee"),
      min_attendee:          @elem.find("##{@resource_name}_min_attendee"),
      teacher_max_income:    @elem.find("##{@resource_name}_teacher_max_income"),
      teacher_min_income:    @elem.find("##{@resource_name}_teacher_min_income"),
      provider_max_income:    @elem.find("##{@resource_name}_provider_max_income"),
      provider_min_income:    @elem.find("##{@resource_name}_provider_min_income"),
      teacher_pay_type:      @elem.find("##{@resource_name}_teacher_pay_type"),
      teacher_pay_flat:      @elem.find("##{@resource_name}_teacher_pay_flat"),
      teacher_pay_variable:  @elem.find("##{@resource_name}_teacher_pay_variable")
    }
    @_attachHandlers()

  triggerRecompute: =>
    $.ajax {
      url: '/classes/calculate_cost.json',
      data: {course: @_sourceData()},
      success: @onRecomputeSuccess,
      error: @onRecomputeError
    }

  check_positive: =>
    for k,v of @fields
      amount = $(v).val()
      amount = amount.replace("$","") if amount
      if !isNaN(amount) && amount < 0
        $(v).addClass('text-danger') 
      else
          $(v).removeClass('text-danger') 


  ### HANDLERS ###

  onRecomputeSuccess: (data, textStatus) =>
    @_setData(data)

  onRecomputeError: (data, textStatus) =>
    alert "error: #{textStatus}, #{JSON.stringify(data)}"

  ### PRIVATE ###

  _setData: (values) ->
    @fields.chalkle_fee.attr('value', parseFloat(values.chalkle_fee).toFixed(2)).highlight_input()
    @fields.processing_fee.attr('value', parseFloat(values.processing_fee).toFixed(2)).highlight_input()
    @fields.teacher_pay_flat.attr('value', '$'+parseFloat(values.teacher_pay_flat).toFixed(2)).highlight_input()
    @fields.teacher_pay_variable.attr('value', parseFloat(values.teacher_pay_variable).toFixed(2)).highlight_input()
    @fields.provider_fee.attr('value', parseFloat(values.provider_fee).toFixed(2)).highlight_input()
    @fields.teacher_min_income.attr('value', '$'+parseFloat(values.teacher_min_income).toFixed(2)).highlight_input()
    @fields.teacher_max_income.attr('value', '$'+parseFloat(values.teacher_max_income).toFixed(2)).highlight_input()
    @fields.provider_min_income.attr('value', '$'+parseFloat(values.provider_min_income).toFixed(2)).highlight_input()
    @fields.provider_max_income.attr('value', '$'+parseFloat(values.provider_max_income).toFixed(2)).highlight_input()
    @check_positive()

  _sourceData: ->
    result = {}
    for field_name in @input_field_names
      result[field_name] = @fields[field_name].val()
    result

  _inputFields: ->
    @fields[field_name] for field_name in @input_field_names

  _attachHandlers: ->
    for field in @_inputFields()
      field.on 'change', @triggerRecompute
    @triggerRecompute()


$.fn.courseCostCalculator = (options) ->
  @each ->
    element = $(this)
    dataName = 'courseCostCalculator'

    return if element.data(dataName)
    element.data dataName, new LessonCostCalculator(this, options)

$.fn.highlight_input = () ->
  if this.effect
    this.effect("highlight", {}, 1500);
