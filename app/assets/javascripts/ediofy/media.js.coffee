jQuery ($) ->
  $('li.media_collection').each ->
    $collection = $(this)
    $images = $collection.find 'span.thumb'
    if $images.length > 1
      $collection.on 'mousemove', '.thumbs', (event) ->
        hoverWidth = $(event.target).width() / $images.length
        index = Math.floor(event.offsetX / hoverWidth)
        $images.css('z-index', 1).eq(index).css 'z-index', 2

  $aside = $('#side')
  $aside.find('.aside-box').each ->
    $asideBox = $(this)
    $addLink = $asideBox.find 'h3 .add a'
    $addForm = $asideBox.find('form.add-form').hide()
    $addLink.click (event) ->
      event.preventDefault()
      $addForm.toggle()

  $userCollectionSelect = $aside.find('#user_collection_id')
  $userCollectionNew = $aside.find('#user_collection_name').parent().hide()
  $userCollectionSelect.change (event)->
    if this.selectedIndex == 1 && $(this.parentNode).find('#user_collection_name').length==0
      $userCollectionNew.show()
    else
      $userCollectionNew.hide()

  $('.media-detail .image a').fancybox
    padding: 5

  $('ul.question-media a').fancybox
    type: 'iframe'
    arrows: false
    width: 620
    scrolling: false
    padding: 5

  $('a.collection-slideshow').click (event) ->
    event.preventDefault()
    items = []
    $('.media-items a').each ->
      $link = $(this)
      if $link.data 'full'
        item =
          href: $link.data 'full'
          title: $link.attr 'title'
        items.push item
    $.fancybox items

  $(document).ready ->
    loadAudioPlayer()

    if $('.video-show').length > 0
      trackMediaTime($('.video-show'), 'video')

    if $('.audio-show').length > 0
      trackMediaTime($('.audio-show'), 'audio')

    trackPdfTime()

  trackMediaTime = (obj, media_type) ->
    start_t = 0
    end_t = 0
    total_t = 0
    ended = false

    obj.on 'play', (event) ->
      start_t = @currentTime
      return

    obj.on 'pause', (event) ->
      total_t += @currentTime - start_t
      media_file_id = $(@).data('id')
      updateVideoTime(media_file_id, media_type, total_t)
      return

    obj.on 'timeupdate', (event) ->
      if not ended && @duration - @currentTime < 0.5
        total_t += @currentTime - start_t
        ended = true
        updateVideoTime($(this).data('id'), media_type, total_t)
        return

  trackPdfTime = () ->
    $('.pdf-spent-mins').change ->
      $.ajax
        url: '/media/update_cpd'
        type: 'POST'
        data: { media_file_id: $(@).data('id'), media_type: 'pdf', played_duration: $(this).val() }
        success: (result) ->
          console.log 'success'
          return
      return

  updateVideoTime = (media_file_id, media_type, played_duration) ->
    $.ajax
      url: '/media/update_cpd'
      type: 'POST'
      data: { media_file_id: media_file_id, media_type: media_type, played_duration: played_duration }
      success: (result) ->
        console.log 'success'
        return

  loadAudioPlayer = ->
    player = $('#content-audio-player')[0]
    if player
      progress_bar = $('#progressbar')
      time = $('#currentTime')
      maxtime = $('#duration')
      play_button = $('.playerCOntroller .play i')
      progress_bar.progressbar({
        value : player.currentTime,
      });
      player.onloadedmetadata = ->
        $('.audioPlayer').show()
        duration = player.duration
        progress_bar.progressbar 'option', 'max': duration
        maxtime.text getTime(duration)
        return

      player.addEventListener 'timeupdate', (->
        progress_bar.progressbar 'value', player.currentTime
        time.text getTime(player.currentTime)
        return
      ), false

      player.addEventListener 'ended', (->
        play_button.toggleClass 'fa-pause'
        play_button.toggleClass 'fa-play'
        return
      ), false

      progress_bar.click (e) ->
        info = getProgressBarClickInfo($(this), e)
        player.currentTime = player.duration / info.max * info.value
        return

      play_button.click ->
        player[if player.paused then 'play' else 'pause']()
        $(this).toggleClass 'fa-pause', !player.paused
        $(this).toggleClass 'fa-play', player.paused
        return

      $('.playerCOntroller .forward i').on 'click', (event) ->
        event.preventDefault()
        player.currentTime +=3

      $('.playerCOntroller .backward i').on 'click', (event) ->
        event.preventDefault()
        player.currentTime -=3

      $('.audioController .volume-down i').on 'click', (event) ->
        event.preventDefault()
        if player.volume > 0.1 then player.volume -= 0.2
        updateVolumeBar(player.volume)


      $('.audioController .volume-up i').on 'click', (event) ->
        event.preventDefault()
        if player.volume < 1 then player.volume += 0.2
        updateVolumeBar(player.volume)
      $('.audioController .volumn-progressbar span').on 'click', (event) ->
        volume = $(this).data('position')/5.0
        player.volume = volume
        updateVolumeBar(volume)


  updateVolumeBar = (volume) ->
    bars = $('.audioController .volumn-progressbar span')
    bars.removeClass('active')
    for bar, index in bars
      if (volume)*5 >= $(bar).data('position')
        $(bar).addClass('active')

  getTime = (t) ->
    m = ~ ~(t / 60)
    s = ~ ~(t % 60)
    (if m < 10 then '0' + m else m) + ':' + (if s < 10 then '0' + s else s)


  getProgressBarClickInfo = (progress_bar, e) ->
    offset = progress_bar.position()
    x = e.pageX - (offset.left)
    # or e.offsetX (less support, though)
    y = e.pageY - (offset.top)
    # or e.offsetY
    max = progress_bar.progressbar('option', 'max')
    value = x * max / progress_bar.width()
    {
      x: x
      y: y
      max: max
      value: value
    }

  $questionsBox = $('body.gmep-media-show .questions-box')
  $questionItems = $questionsBox.find('ol li')
  if $questionItems.length > 5
    $questionItems.filter(':gt(4)').hide()
    $button = $("<a href='#more'>#{$questionsBox.data().more}</a>").click (event) ->
      event.preventDefault()
      $questionItems.show()
    $questionsBox.find('.action').prepend $button

  floatActionsToggle = ->
    $floatDiv.toggle $(window).scrollTop() < ($(document).height() - $(window).height() - 200)

  if ($floatActions = $('.float-actions')).length > 0
    $form = $floatActions.parents('form')
    $floatDiv = $('<div id="float-actions-container" />')
    $floatActions.clone().appendTo $floatDiv
    $floatDiv.appendTo $('body')
    $floatDiv.find('input[type="submit"]').click (event) ->
      event.preventDefault()
      $form.submit()

    $(window).scroll floatActionsToggle

    floatActionsToggle()
