tagger =
  setup: ->
    @setupTagger()

  setupTagger: ->
    tagger.renderTaggers 'input.tagger'

  renderTaggers: (elements) ->
    $els = $(elements).each (index, el) ->
      element = $(el)
      source = element.data('tagger-source')
      queryParam = element.data('tagger-query-param') or 'q'
      hintText = element.data('tagger-hint') or 'Tags'
      noResultsText = element.data('tagger-no-results') or 'No matching results'
      initialData = element.data('tagger-initial')
      element.tokenInput source,
        hintText: hintText
        placeholder: 'Tags'
        theme: 'facebook'
        noResultsText: noResultsText
        queryParam: queryParam
        prePopulate: initialData
        allowFreeTagging: true
        tokenValue: 'name'
        tokenDelimiter: ':'

    $('[data-tag]').click (event) ->
      $els.eq(0).tokenInput 'add', { name: $(event.currentTarget).data('tag') }

  # Adds taggers to inputs without them already
  addWidgets: ->
    widgets = $('.tagger_widget')
    $.each widgets, (i, widget) ->
      tagger.renderTaggers $(widget).find('input.tagger') if $(widget).find('.token-input-list').size() is 0

tagbuilder =
  setup: ->
    $('li.tag-builder').each (index, el) ->
      $el = $(el)
      $els = {}
      $els['tagger'] = $el.parent().find('input.tagger')
      $els['parent'] = $el.find('.tag-builder-parent')
      $els['child'] = $el.find('.tag-builder-child')
      ($els['value'] = $el.find('.tag-builder-value')).keypress (event) =>
        if event.keyCode is 10 or event.keyCode is 13
          event.preventDefault()
          tagbuilder.addTag $els
      ($els['button'] = $el.find('.tag-builder-button')).click (event) =>
        event.preventDefault()
        tagbuilder.addTag $els

  addTag: ($els) ->
    unless (value = $.trim($els['value'].val())) is ''
      tag = "#{$els['parent'].val()}:#{$els['child'].val()}=#{value}"
      $els['tagger'].tokenInput 'add', name: tag
      $els['value'].val ''

$(document).ready ->
  tagger.setup()
  tagbuilder.setup()