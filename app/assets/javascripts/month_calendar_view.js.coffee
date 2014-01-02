#= require plugins/lessons_index.js

$(document).ready ->
  $('#lessons_index').lessonsIndex()

  $(document).on "ajax:success", '[data-append]', (evt, data, status, xhr) ->
    target_id = $(this).attr('data-append')
    $("##{target_id}").append(data)

  $(document).on "ajax:before", '[data-remove-on-success]', (evt, data, status, xhr) ->
    $(this).addClass('ajax-sending');

  $(document).on "ajax:error", '[data-remove-on-success]', (evt, data, status, xhr) ->
    $(this).remove('ajax-error')

  $(document).on "ajax:success", '[data-remove-on-success]', (evt, data, status, xhr) ->
    $(this).remove()
