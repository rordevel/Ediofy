jQuery ($) ->
  popupActive = false
  navigationPosition = 0
  $button = $('#notifications-button')
  $buttonClear = $button.find 'a.clear'
  $overlay = $('#notifications-overlay').hide()
  $popup = $('#notifications-popup').hide()
  $popupWrapper = $popup.find '.notifications-wrapper'
  $notifications = $popup.find '.notification'
  $navigationNext = $popup.find 'nav .next'
  $navigationPrev = $popup.find 'nav .prev'
  $navigation = $popup.find 'nav span'
  $popupClear = $popup.find '.clear'
  $body = $('body')
  notificationWidth = $notifications.eq(0).width()

  $list = $('body .content ol.notifications li.notification')
  $list.on 'click', 'a.name', (event) ->
    event.preventDefault()
    $(event.delegateTarget).find('article.notification').slideToggle 200

  positionPopup = ->
    if popupActive
      $overlay.height window.document.height
      # Position the popup in the middle of the window
      $popup.css 'top', (window.innerHeight * 0.5 + window.scrollY) - ($popup.height() * 0.5) + 'px'

  openPopup = ->
    popupActive = true
    $overlay.show()
    $popup.show()
    positionPopup()

  closePopup = ->
    popupActive = false
    $overlay.hide()
    $popup.hide()

  setupNavigation = ->
    if $notifications.length > 1
      $navigationNext.addClass 'active'

  clickNavigation = (e) ->
    $this = $(this)
    if $this.hasClass 'active'
      direction = 1
      unless $this.hasClass 'next' then direction = -1
      navigate navigationPosition + direction

  navigate = (position) ->
    updatePosition position
    left = position * -600 + 'px'
    $popupWrapper.stop(true, false).animate { left: left }, 400, 'easeOutQuad'

  updatePosition = (position) ->
    navigationPosition = position
    $navigationNext.toggleClass 'active', position < $notifications.length-1
    $navigationPrev.toggleClass 'active', position != 0

  clearAll = ($this) ->
    $.ajax
      url: $this.attr 'href'
      dataType: 'json'
      type: 'PUT'
    $button.hide()

  setupNavigation()

  $navigation.click clickNavigation

  $(window).on 'resize scroll', positionPopup

  $overlay.click closePopup

  $popupClear.add($buttonClear).click (e) ->
    e.preventDefault()
    if confirm('Are you sure you want to clear all your notifications?')
      clearAll $(this)
      closePopup()

  $button.find('.notifications')
    .click (e) ->
      e.preventDefault()
      openPopup()
    .hover ->
      $button.addClass 'hover'
    , ->
      $button.removeClass 'hover'

  $popupWrapper.width $notifications.length * notificationWidth + 'px'