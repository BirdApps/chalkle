class FilterSelector
  constructor: (element, lessons_index) ->
    @elem = $(element)
    @index = lessons_index
    @_attachHandlers()

  ### HANDLERS ###

  onFilterSelected: (event) =>
    try
      element = $(event.target)
      target_url = @_buildTarget element.attr('href'), @index.activeViewName()
      element.attr 'href', target_url
    catch error
      console.log error

  ### PRIVATE ###

  _buildTarget: (url, view_name) ->
    if url.match(/\?/)
      joiner = '&'
    else
      joiner = '?'
    "#{url}#{joiner}view=#{view_name}"

  _attachHandlers: () ->
    @elem.find('a.dropdown-link').on 'click', @onFilterSelected


$.fn.filterSelector = (lessons_index_id) ->
  @each ->
    element = $(this)
    dataName = 'filterSelector'
    index = $(lessons_index_id).data('lessonsIndex')

    return if element.data(dataName)
    element.data dataName, new FilterSelector(this, index)
