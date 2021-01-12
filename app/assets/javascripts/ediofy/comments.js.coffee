$(document).on 'ready', ->
  $('.reply-btn').data 'remote', false

  $('body').on 'click', '.cancel-comment', ->
    if $(this).parents('form').find('input[name="comment[parent_id]"]').length
      $(this).parents('.com-box').remove()
    else
      form = $(this).parents('form')
      body = form.find('#comment_comment_input div[contenteditable="true"]').html('<p><br /></p>')
      form.find('.fr-wrapper').addClass('show-placeholder')

  $('body').on 'click', '#results-listing .cancel-comment', ->
    $('.reply-btn').data 'remote', true

  $('body').on 'click', '.reply-btn', (e) ->
    e.preventDefault()




$(document).on 'ready', ->
  $('.comment-edit-link').data 'remote', false

  $('body').on 'click', '.cancel-comment', ->
    if $(this).parents('form').find('input[name="comment[parent_id]"]').length
      $(this).parents('.com-box').remove()
    else
      form = $(this).parents('form')
      body = form.find('#comment_comment_input div[contenteditable="true"]').html('<p><br /></p>')
      form.find('.fr-wrapper').addClass('show-placeholder')

  $('body').on 'click', '#results-listing .cancel-comment', ->
    $('.reply-btn').data 'remote', true

  $('body').on 'click', '.comment-edit-link', (e) ->
    e.preventDefault()

