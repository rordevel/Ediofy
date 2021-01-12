class MediaBrowser
  constructor: (options={}) ->
    $.extend this, options

    @mediaIndexUrl ||= $('[data-media-index-url]').data 'media-index-url'
    @addMediaUrl ||= $('[data-add-media-url]').data 'add-media-url'
    @events = false

    @el ||= $('<div class="media-browser"></div>')
    @titleEl = $('<hgroup></hgroup>').appendTo @el
    @titleGalleryEl = $('<h2>Gallery</h2>').appendTo @titleEl
    @titleMediaIndexEl = $('<h3></h3>').hide().appendTo @titleEl
    @contentEl = $('<div class="content"></div>').appendTo @el

    @contentMediaIndexEl = $('<div class="infinite-table"></div>').appendTo @contentEl
    @contentMediaIndexItemsEl = $('<div class="items"></div>').appendTo @contentMediaIndexEl
    @contentMediaIndexPaginationEl = $('<div class="container"><div class="text-center"><div class="pagination-loadmore"></div></div></div>').appendTo @contentMediaIndexEl

    @contentMediaCollectionEl = $('<div class="media-collection"></div>').appendTo @contentEl
    @mediable ||= "question"

  attachEvents: ->
    @events = true
    @titleGalleryEl.click =>
      @showMediaIndex()
    @titleMediaIndexEl.click =>
      @showMediaIndex()
    @contentEl.on 'submit', '.media-search form', (e) =>
      e.preventDefault()
      @loadMediaIndex "#{@mediaIndexUrl}?#{$(e.currentTarget).serialize()}"
    @contentEl.on 'click', '.media-search a, .pagination a', (e) =>
      e.preventDefault()
      @loadMediaIndex $(e.currentTarget).attr('href')
    @contentEl.on 'click', 'li.media_collection > a', (e) =>
      e.preventDefault()
      @loadMediaCollection $(e.currentTarget).attr('href')
    @contentEl.on 'click', 'li.media:not(.media_collection) > a', (e) =>
      e.preventDefault()
      @addMedia /\d+$/.exec($(e.currentTarget).attr('href'))[0], @mediable

  loading: ->
    $.fancybox.showLoading()

  loaded: ->
    $.fancybox.hideLoading()

  open: ->
    $.fancybox
      content: @el
      width: 930
      minWidth: 930
      height: 400
      minHeight: 400
      autoSize: true
      fitToView: true
    @attachEvents() unless @events
    @loadMediaIndex() unless @contentMediaIndexItemsEl.children().length

  loadMediaIndex: (url=null) ->
    @loading()
    url ||= @mediaIndexUrl
    @pending?.abort()
    @pending = $.get(url: url + "?mediable=#{@mediable}", dataType: "script")
      # .done (data) =>
        # window.mediaIndex = data
        # @contentMediaIndexEl.empty()
        # @contentMediaIndexEl.append(data)
        # @contentMediaIndexEl.show()
        # @titleMediaIndexEl.text($(".content .info h2", data).text()).show()
        # @contentMediaCollectionEl.hide()
        # @titleMediaIndexEl.text 'All Media'
        # $.fancybox.update()
      .fail =>
        alert "There was an error loading the gallery. Please try again soon."
      .always =>
        @loaded()

  showMediaIndex: ->
    @contentMediaCollectionEl.hide()
    @titleMediaIndexEl.text 'All Media'
    @contentMediaIndexEl.show()

  loadMediaCollection: (url) ->
    @loading()
    @pending?.abort()
    @pending = $.get(url, dataType: "script")
      .done (data) =>
        @contentMediaCollectionEl.empty()
          .append($('.content .media-items', data))
          .show()
        @contentMediaIndexEl.hide()
        @titleMediaIndexEl.text $(".content .info h2", data).text()
      .fail =>
        alert "There was an error loading the collection. Please try again soon."
      .always =>
        @loaded()

  addMedia: (media_id, mediable) ->
    if $("#media_#{media_id}", @addMediaTo).length
      return alert "Already added this media."
    @loading
    @pending?.abort()
    @pending = $.get("#{@addMediaUrl}/#{media_id}?mediable=#{mediable}", dataType: "html")
      .done (data, status, xhr) =>
        @addMediaTo?.show().append xhr.responseText
        $.fancybox.close()
      .fail =>
        alert "Couldn't add that media. Please try again soon."
      .always =>
        @loaded()

jQuery ($) ->

  toggleNoQuestionsText = ->
    if $questionForm.find('ol.incorrect-answer:visible').length > 0
      $questionForm.find('li.no-answers').hide()
    else
      $questionForm.find('li.no-answers').show()

  $questionForm = $('form.question')
  $conversationForm = $('form.conversation')
  $questionFormAnswers = $questionForm.find('.question-answers')

  if $questionForm.length

    # ---------- Question Media ----------

    ($questionFormMedia = $questionForm.find('li.media ul')).find('.thumb a').fancybox()
    $questionFormMedia.hide() if $questionFormMedia.find('li').length == 0

    $questionFormMedia.on 'click', 'li.media a[data-remove-media]', (e) ->
      e.preventDefault()
      $("#media_#{$(this).data('remove-media')}").remove()

    mediaBrowser = new MediaBrowser addMediaTo: $questionFormMedia, mediable: "question"
    $questionForm.on 'click', 'li.media a[data-add-media]', (e) ->
      e.preventDefault()
      mediaBrowser.open()
  if $conversationForm.length
    @mediable = "conversation"
    ($conversationFormMedia = $conversationForm.find('li.media ul')).find('.thumb a').fancybox()
    $conversationFormMedia.hide() if $conversationFormMedia.find('li').length == 0

    $conversationFormMedia.on 'click', 'li.media a[data-remove-media]', (e) ->
      e.preventDefault()
      $("#media_#{$(this).data('remove-media')}").remove()

    mediaBrowser = new MediaBrowser addMediaTo: $conversationFormMedia, mediable: "conversation"
    $conversationForm.on 'click', 'li.media a[data-add-media]', (e) ->
      e.preventDefault()
      mediaBrowser.open()