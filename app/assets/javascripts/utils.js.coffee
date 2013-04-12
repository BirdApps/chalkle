$(document).ready ()->

  $('[data-toggle="checkboxes"] input[type=checkbox]').on 'change', ()->
    wrapper = $(@).closest('[data-toggle="checkboxes"]')
    if wrapper.find('input[type=checkbox]:checked').length
      wrapper.find('a').text("Deselect all")
      wrapper.attr('class', 'checked')
    else
      wrapper.find('a').text("Select all")
      wrapper.attr('class', 'unchecked')

  $('[data-toggle="checkboxes"] a.checkbox-toggle-button').on 'click', (e)->
    e.preventDefault()
    wrapper = $(@).closest('[data-toggle="checkboxes"]')
    state = wrapper.attr('class')
    if state == "unchecked"
      wrapper.find('input[type=checkbox]').prop('checked', true).change()

    if state == "checked"
      wrapper.find('input[type=checkbox]').prop('checked', false).change()

