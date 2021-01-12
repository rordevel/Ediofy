$ ->
  $('a#createplaylistlink').click ->
    $('.newplaylistblock').removeClass('hidden')
    $('.addtoplaylistblock').addClass('hidden')
    $('#back-playlistlink').removeClass('hidden')
    $('#createplaylistlink').addClass('hidden')

  $('a#back-playlistlink').click ->
    $('.newplaylistblock').addClass('hidden')
    $('.addtoplaylistblock').removeClass('hidden')
    $('#back-playlist').addClass('hidden')
    $('#createplaylistlink').removeClass('hidden')

  $('tr.row.plrow.spaceUnder').click (evt) ->
    if $('.enable-edit-sort').hasClass('hidden')
      return
    if evt.target.tagName == 'I'
      return
    url = $(@).attr('url')
    window.location = url;

  $('a.enable-edit-sort').click ->
    sortable('#contents', 'enable');
    $('.plist.sortable_mark.hidden.js-handle').removeClass('hidden')
    $('.enable-edit-sort').addClass('hidden')
    $('.disable-edit-sort').removeClass('hidden');
  
  $('a.disable-edit-sort').click ->
    sortable('#contents', 'disable');
    $('.plist.sortable_mark.js-handle').addClass('hidden')
    $('.disable-edit-sort').addClass('hidden')
    $('.enable-edit-sort').removeClass('hidden');