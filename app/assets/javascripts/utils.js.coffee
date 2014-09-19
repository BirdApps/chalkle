Utils = {}
#Checks and unchecks a group of checkboxes.
#Set data-toggle="checkboxes" on an element that wraps a group of checkboxes
#Set an a.checkbox-toggle-button inside said container.
Utils.CheckBoxChecker = {}

Utils.CheckBoxChecker.watchBoxes = ()->
  $('[data-toggle="checkboxes"] input[type=checkbox]').on 'change', ()->
    wrapper = $(@).closest('[data-toggle="checkboxes"]')
    if wrapper.find('input[type=checkbox]:checked').length
      wrapper.find('a.checkbox-toggle-button').text("Deselect all")
      wrapper.removeClass("unchecked").addClass("checked")
    else
      wrapper.find('a.checkbox-toggle-button').text("Select all")
      wrapper.removeClass("checked").addClass("unchecked")
  
Utils.CheckBoxChecker.watchButtonClick = ()->
  $('[data-toggle="checkboxes"] a.checkbox-toggle-button').on 'click', (e)->
    e.preventDefault()
    wrapper = $(@).closest('[data-toggle="checkboxes"]')
    if wrapper.hasClass "unchecked"
      setTimeout(()->
        wrapper.find('input[type=checkbox]').prop('checked', true).trigger "change"
      , 20)

    if wrapper.hasClass "checked"
      wrapper.find('input[type=checkbox]').prop('checked', false).change()

Utils.CheckBoxChecker.init = ()->
  Utils.CheckBoxChecker.watchButtonClick()
  Utils.CheckBoxChecker.watchBoxes()


$(document).ready ()->
  Utils.CheckBoxChecker.init()
