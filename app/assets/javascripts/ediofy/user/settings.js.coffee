jQuery ($) ->


  $('.datewindow').datepicker({format: 'dd/mm/yyyy'});

  
  # Ticking a parent tag checkbox, ticks its children
  # Don't do the auto-child selector on the new questions screen
  $('body:not(.ediofy-questions-new) ol.tags input[type=checkbox]').on 'click', (e) ->
    $(this).closest('li').find('input[type=checkbox]').prop 'checked', this.checked
    unless this.checked
      if ($parentCheckbox = $(this).closest('li').parents('li').find('> label > input')).prop 'checked'
        $parentCheckbox.prop 'checked', false


  $tagsList = $('ol.tags').isotope
    itemSelector: 'tag'
    masonry:
      columnWidth: 305
    getSortData:
      number: (element) ->
        parseInt $(element).data('index'), 10
    sortBy: 'number'
  $tagsList.find('> li.tag').each ->
    $tagList = $(this)
    $tagLabel = $tagList.find '> label'
    $tagChildren = $tagList.find 'ol'
    if $tagChildren.length
      $tagLabel.before '<span class="expand-tag">Expand</span>'
      $tagChildren.hide()
      $tagExpand = $tagList.find('.expand-tag').click (event) ->
        event.preventDefault()
        $tagChildren.toggle()
        $tagList.toggleClass 'expanded'
        refreshColumns()

  refreshColumns = ->
    $tagsList.isotope 'layout'

  refreshColumns()

  $tagQuickselect = $('nav.tag-quickselect')
  $tagQuickselect.on 'click', 'a', (event) ->
    event.preventDefault()
    $tagsList.find('input').prop 'checked', $(this).is('.all')





  # Range slider outputing the value on the page
  $("body.ediofy-members-settings .privacy ol.choices-group").each ->
    $choiceGroup = $(this)
    $choiceGroup.find('input:checked').parents('.choice').addClass('selected')
    $choiceGroup.find('.choice').on 'click', (e) ->
      $choiceGroup.find('.choice').removeClass('selected')
      $(this).addClass('selected').find('input').prop('checked', true)