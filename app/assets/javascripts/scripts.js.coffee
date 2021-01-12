$ ->
  if $('#sign_up_submit').length
    $('#sign_up_submit').on 'click', (event) ->
      event.preventDefault()
      $('input#user_email').siblings('p.inline-errors').remove();
      email = $('input#user_email').val()
      if validateEmail(email)
        $('#new_user').submit()
      else
        $('input#user_email').after('<p class="inline-errors">invalid email address</p>')
      return
  if $('.delete-content-btn').length
    $('.delete-content-btn').click ->
      elm = $(this)
      bootbox.confirm
        title: 'Delete '+ $(elm).data('type')
        message: 'Are you sure?'
        buttons:
          cancel: label: 'No'
          confirm: label: 'Yes'
        callback: (result) ->
          if result
            $.ajax
              url: $(elm).data('request-url')
              type: 'POST'
              data: { _method: 'DELETE' }
              success: (result) ->
                window.location = location.protocol + '//' + location.host
                return
              error: (request, status, error) ->
                new PNotify(
                  title: status
                  text: request.responseText
                  type: 'error')
                return
          return
      return

  if $('.delete-ann-btn').length
    $('.delete-ann-btn').click ->
      elm = $(this)
      bootbox.confirm
        title: 'Delete '+ $(elm).data('type')
        message: 'Are you sure you want to delete the annoucement?'
        buttons:
          cancel: label: 'No'
          confirm: label: 'Yes'
        callback: (result) ->
          if result
            $.ajax
              url: $(elm).data('request-url')
              type: 'POST'
              data: { _method: 'DELETE' }
              success: (result) ->
                location.reload();
                return
              error: (request, status, error) ->
                new PNotify(
                  title: status
                  text: request.responseText
                  type: 'error')
                return
          return
      return

  createGroupContent = (
    '<div class="row">' +
      '<div class="col-sm-12">' +
        'Groups allow you to share content and create discussions with a select group of members in a private space.' +
        'You can create a public group that is open to all members of the Ediofy community or create private groups that are only able to be viewed by members you invite to join.' +
      '</div>' +

      '<p></p>' +
      '<br>' +
      '<br>' +

      '<div class="row">' +
        '<div class="col-sm-2 text-right">' +
          '<h1 class="light-gray">1.</h1>' +
        '</div>' +
        '<div class="col-sm-9 text-left">' +
          '<h1>Be kind</h1>' +
          'All content and comments posted must be respectful and in the spirit of furthering education. Detrimental, abusive or ' +
          'inappropriate groups and content will be reported and users may have their access to Ediofy revoked. Keep it friendly! ' +
          '<hr>' +
        '</div>' +
      '</div>' +


      '<div class="row">' +
        '<div class="col-sm-2 text-right">' +
          '<h1 class="light-gray">2.</h1>' +
        '</div>' +
        '<div class="col-sm-9 text-left">' +
          '<h1>No Sales</h1>' +
          'Groups or posts promoting the sale of products or drugs are strictly not allowed. '+
          '<hr>' +
        '</div>' +
      '</div>' +

      '<div class="row">' +
        '<div class="col-sm-2 text-right">' +
          '<h1 class="light-gray">3.</h1>' +
        '</div>' +
        '<div class="col-sm-9 text-left">' +
          '<h1>Posting</h1>' +
          'All content posted must be educational in nature and relevant to the groups interest. We all love unlikely animal friends – but  ' +
          'keep it for your mum or other social media sites. We’re here to learn and encourage.'+
        '</div>' +
      '</div>' +
    '</div>'
  )

  if $('.create-group-btn').length
    $('.create-group-btn').click ->
      elm = $(this)
      bootbox.confirm
        title: 'Create New Group'
        message: createGroupContent
        buttons:
          confirm: label: 'Agree'
        callback: (result) ->
          if result
            window.location = location.protocol + '//' + location.host + '/groups/new';

  if $('.destroy-user-btn').length
    $('.destroy-user-btn').click ->
      elm = $(this)
      bootbox.confirm
        title: 'Delete your account'
        message: 'Are you sure you want to permanently delete your account?</br></br>All your information will be deleted including any groups you have created for which you have not transferred ownership/admin permissions.'
        buttons:
          cancel: label: 'No'
          confirm: label: 'Yes'
        callback: (result) ->
          if result
            $.ajax
              url: $(elm).data('request-url')
              type: 'POST'
              data: { _method: 'DELETE' }
              success: (result) ->
                window.location = location.protocol + '//' + location.host
                return
              error: (request, status, error) ->
                new PNotify(
                  title: status
                  text: request.responseText
                  type: 'error')
                return  

          return
      return


  if $('.video-not-encoded').length
    $('.video-not-encoded').click ->
      bootbox.alert('The video content is being encoded. Please wait a couple of minutes and try again.')
  toggle_remove_nested_fields_link(false)
  if $("#media_title").length
    enable_disable_media_submit()
  if $("#link_title").length  
    enable_disable_link_submit()
  if $("#conversation_title").length
    enable_disable_conversation_submit()
  if $("#question_explanation").length
    enable_disable_question_submit()
  $("#media_title, #media_description, #ignored").bind "input change", ->
    if !$("#media-upload-submit").hasClass('upload-in-progress')
      enable_disable_media_submit()
  $("#link_title, #link_url, #ignored, input[name='link[tag_list]']").bind "input change", ->
    enable_disable_link_submit()
  $("#conversation_title, #conversation_description, #conversation_summary, input[name='conversation[tag_list]']").bind "input change", ->
    enable_disable_conversation_submit()
  $(document).on "input","#question_explanation, #question_body, .answer-body, #question-form input", ->
    enable_disable_question_submit()
  if $(".add_nested_fields_link").length
    $(".add_nested_fields_link").each ->
      $(this).on "click", ->
        enable_disable_question_submit()
  $(":input").bind "keyup change", ->
    if $(this).is 'input[type=email]'
      if !validateEmail($(this).val())
        $(this).attr('style', 'border-bottom-color: red !important')
      else
        $(this).attr('style', 'border-bottom-color: #17b2ff !important')
    else if $(this).is('input[type=url]') or $(this).is('input[type=password]') or $(this).is('input[type=text]')
      if $(this).attr('id') == 'token-input-ignored' or $(this).attr('id') == 'ignored'
        $(this).parents('.two-lab .tagger').attr('style', 'border-bottom-color: #17b2ff !important')
      else
        $(this).attr('style', 'border-bottom-color: #17b2ff !important')
  $(":input").bind "focusout", ->
    if $(this).attr('id') == 'token-input-ignored' or $(this).attr('id') == 'ignored'
      $(this).parents('.two-lab .tagger').attr('style', 'border-bottom-color: #aac7dd !important')
    else
      $(this).attr('style', '')
  $('#user-contribution-history-nav-tabs li a').on 'click', ->
    $("#content_type option:selected").prop('selected', false)
    $("#sort_by option:selected").prop('selected', false)
    $('#user-contribution-history-nav-tabs li').removeClass 'active'
    $(this).parents('li').addClass 'active'
    return
  #$('#comment_comment').mention
    #delimiter: '@'
    #sensitive: true
    #queryBy: [ 'username', 'name' ]
    #ajax: true
    #ajaxUrl: '/users/notifications/mentions'
    #users: [ {} ]
  $(".select-ans").on 'click', ->
    id = $(this).attr('id')
    #$('.correct').removeClass 'correct'
    $(this).parents().find('div.selected-answer').removeClass('selected-answer')
    $('#answer-' + id).addClass 'selected-answer'
    $('input#user_exam_question_selected_answer_attributes_answer_id').val id
    $('.user_exam_question').submit()
  $(".remove_image").on 'click', ->
    id = $(this).attr("removed")
    $("#"+id).hide();
    $("input#"+id).val(1);
  $('a.not-signed-in-alert').on 'click', ->
    alert 'You need to sign in'

  $('a.get-started').click ->
    $('html, body').animate { scrollTop: $('h2.your-interests').offset().top - 90 }, 2000
    return

  # $('#results-listing .infinite-table').infinitePages
  #  debug: true
  #  buffer: 200 # load new page when within 200px of nav link
  #  # context: '.footer' # define the scrolling container (defaults to window)
  #  loading: ->
  #    # jQuery callback on the nav element
  #    $(this).text("Loading...")
  #  success: ->
  #    # called after successful ajax call
  #  error: ->
  #    # called after failed ajax call
  #    $(this).text("Trouble! Please drink some coconut water and click again")

  if $('#results-listing').length
    url = $('#results-listing').attr('data-url')
    if typeof url != 'undefined'
      $.ajax
        type: 'GET'
        url: url
        dataType: 'script'

  active_shared_content_tab = ''
  setTimeout (->
    $("#related-content #related-content-tabs .active a").first().trigger('click')
    return
  ), 10
  
  $('#related-content').on 'click', '.tablink,#related-content-tabs a', (e) ->

    e.preventDefault()

    if active_shared_content_tab != $(this).attr('data-link')
      url = $(this).attr('data-url')
      if typeof url != 'undefined'
        $("#related-content #related-content-tabs li").removeClass('active')
        $(this).parent('li').addClass('active')
        pane = $(this)
        href = @hash
        active_shared_content_tab = $(this).attr('data-link')
        $.ajax
          type: 'GET'
          url: url
          dataType: 'script'
          beforeSend: ->
            $(".infinite-table .items").text("")
            $('#related-content .infinite-table .load-more').html("")
            return
          error: (data) ->
            # alert("There was a problem");
            return
          success: (data) ->
            pane.tab 'show'
            return
      else
        $(this).tab 'show'
    return

  # setupHtmlInputs()
  tweetButtons()
  shareButtons()

  $('.reply-form-toggle').on 'click', ->
    $('#reply_comment_form_'+$(this).attr('id')).toggle()
    return

#  audiojs.events.ready ->
#    ajs = audiojs.createAll()
#    $('audio').prop 'controls', false

  $('#selector .close').on 'click', ->
    $(this).parents('.tab-pane').removeClass 'active'
    $('.nav-tabs li').removeClass 'active'
    return
  return

@clearMetaContents = ()->
  $(".url-meta-tags .best-image").css('background-image', 'none')
  $(".url-meta-tags .best-description p").html("")
  $(".url-meta-tags .best-description span").text('')
  $(".url-meta-tags").removeAttr('href')
  $("input#link_page_description").val('')
  $("input#link_page_image").val('')
  $(".url-meta-tags .close-img").hide()
  $(".url-meta-tags").removeClass('getdata')
@setupHtmlInputs = (context = document.body) ->
  $('.html_text', context).each ->
    $this = $(this)
    $textarea = $this.find 'textarea'
    field_id = $textarea.attr 'id'
    toolbar_id = $this.find('.html-input-toolbar').attr 'id'
    editor = new wysihtml5.Editor field_id,
      toolbar: toolbar_id
      parserRules: wysihtml5ParserRules
      style: false
      stylesheets: '/assets/wysihtml5.css'
    $textarea.data {editor}

tweetButtons = ->
  tweet_url = "https://twitter.com/intent/tweet?source=tweetbutton"
  $('.twitter-share-button').each (index, element) ->
    $button = $(this)
    url = $button.data 'url'
    text = $button.data 'text'
    window_url = encodeURI tweet_url + '&text=' + text + '&url=' + url
    $button.data 'tweet-url', window_url
    $button.click (e) ->
      e.preventDefault()
      window.open $(this).data('tweet-url'), 'tweetWindow', 'width=550,height=350,status=0,toolbar=0,menubar=0'

shareButtons = ->
  $('#side .share a').click (e) ->
    e.preventDefault()
    window.open $(this).attr('href'), 'shareWindow', 'width=550,height=350,status=0,toolbar=0,menubar=0'

# link new url meta information to show
showMetaContents = ()->
  link = $("input#link_url").val()
  if(link.length)
    data = url: link
    $.post "/links/parse.json",data: data, (response) ->
      $(".url-meta-tags").addClass('getdata')
      if(response["status"] == "success")
        $(".url-meta-tags .best-image").css('background-image', "url('"+response['page_info']['image']+"')")
        $(".url-meta-tags .best-description p").html(response['page_info']['description'])
        $(".url-meta-tags .best-description span").text(response['page_info']['host'])
        $(".url-meta-tags").attr('href', response['page_info']['host'])
        $("input#link_page_image").val(response['page_info']['image'])
        $(".url-meta-tags .close-img").show()
      else
        $(".url-meta-tags .best-image").css('background-image', 'none')
        $(".url-meta-tags .best-description p").html(response["message"])
        $("input#link_page_description").val('')
        $("inpudisplayCellt#link_page_image").val('')
  else
    $(".url-meta-tags .best-image").css('background-image', 'none')
    $(".url-meta-tags .best-description p").html('')
    $(".url-meta-tags .best-description span").text('')
    $(".url-meta-tags").removeAttr('href')
    $("input#link_page_description").val('')
    $("input#link_page_image").val('')
    window.clearMetaContents()
  return

toggle_remove_nested_fields_link = (elm)->
  if $(elm).hasClass("add_nested_fields_link")
    if $('.answer-body:visible').length+1 <= 2
      $('.remove_nested_fields_link').hide()
    else
      $('.remove_nested_fields_link').show()
  else
    if $('.answer-body:visible').length-1 <= 2
      $('.remove_nested_fields_link').hide()
    else
      $('.remove_nested_fields_link').show()    
  set_order()  

set_order = ->
  alphabets = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
  setTimeout (->
    $('h5.order').filter(':visible').each (index, value) ->
      if index > 25
        $(this).text alphabets[0] + alphabets[index - 26]
      else
        $(this).text alphabets[index]
  ), 100


$(document).ready ->
  set_order()
  $("#add-answer").on 'click', ->
    #set_order()
    toggle_remove_nested_fields_link($(this))
  $('form').on 'click', '.remove-answer', (event) ->
    toggle_remove_nested_fields_link($(this))
  if $('.banner-slider').length
    $('.banner-slider').slick
      slidesToShow: 1
      slidesToScroll: 1
      arrows: true
      adaptiveHeight: true
      dots: false
      asNavFor: '.inner-slider'
      infinite: true
      speed: 500
      fade: true
    $('.inner-slider').slick
      slidesToShow: 4
      slidesToScroll: 1
      asNavFor: '.banner-slider'
      dots: false
      adaptiveHeight: true
      focusOnSelect: true
      responsive: [
        {
          breakpoint: 768
          settings:
            arrows: false
            slidesToShow: 3
        }
        {
          breakpoint: 480
          settings:
            arrows: false
            slidesToShow: 2
            dots: true
        }
      ]
  if($("input#link_url").length)
    showMetaContents();
  typingTimer = undefined
  doneTypingInterval = 2000
  #time in ms, 5 second for example
  $input = $('input#link_url')
  $input.on 'keyup', ->
    clearTimeout typingTimer
    typingTimer = setTimeout(showMetaContents, doneTypingInterval)
    return
  $input.on 'down', ->
    clearTimeout typingTimer
    return
  return 
# link new url meta information to show ends here

validateEmail = (Email) ->
  pattern = /^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/
  if $.trim(Email).match(pattern) then true else false

enable_disable_media_submit = () ->
  if $('#media_title').val() != '' or $('#media_description').val() != '' or $('#ignored').val() != ''
    $("#media-upload-submit").prop('disabled', false)
  else
    $("#media-upload-submit").prop('disabled', true)

enable_disable_link_submit = () ->
  if $('#link_title').val() != '' or $('#link_url').val() != '' or $('#ignored').val() != '' or $("input[name='link[tag_list]']").val() != ''
    $('button[type=submit]').prop('disabled', false)
  else
    $('button[type=submit]').prop('disabled', true)

enable_disable_conversation_submit = () ->
  if $('#conversation_title').val() != '' or $('#conversation_description').val() != '' or $("input[name='conversation[tag_list]']").val() != ''
    $('#conversation-submit-btn').prop('disabled', false)
  else
    $('#conversation-submit-btn').prop('disabled', true)

enable_disable_question_submit = () ->
  valid_answers = false
  valid_references = false
  
  $('.answer-body').each ->
    if $(this).val() != ''
      valid_answers = true
    else
      valid_answers = false
  
  $('.nested_question_references input').each ->
    if $(this).val() != ''
      valid_references = true
    else
      valid_references = false
  if $('#question_title').val() != '' or $('#question_body').val() != '' or $('#question_explanation').val() != '' or $("input[name='question[tag_list]']").val() != '' or valid_answers or valid_references
    $('#question-submit-btn').prop('disabled', false)
  else
    $('#question-submit-btn').prop('disabled', true)

$(document).ready ->
  #WYSIWYG Editor
  comment_editor = $('#comment_comment_input textarea')
  explanation_editor = $('textarea#question_explanation')
  about_editor = $('textarea#user_about')

  explanation_editor.froalaEditor
    key: froala_editor_key
    toolbarBottom: true
    placeholderText: 'Include an explanation to help your peers understand the correct answer…'
    toolbarButtons: [
      'bold'
      'italic'
      'underline'
      '|'
      'formatOL'
      'formatUL'
      '|'
      'quote'
    ]

  about_editor.froalaEditor
    key: froala_editor_key
    toolbarBottom: true
    placeholderText: ''
    toolbarButtons: [
      'bold'
      'italic'
      'underline'
      '|'
      'formatOL'
      'formatUL'
      '|'
      'quote'
    ]

  
  # Define config for At.JS.
  config = 
    at: '@'
    displayTpl: '<li>${username} - ${name}</li>'
    insertTpl: '@${username}'
    data: null
    callbacks: remoteFilter: (query, callback) ->
      $.getJSON '/users/notifications/mentions?q=' + query, (data) ->
        console.log data
        callback data
        return
      return
  # Initialize editor.
  $(comment_editor).on('froalaEditor.initialized', (e, editor) ->
    editor.$el.atwho config
    editor.events.on 'keydown', ((e) ->
      if e.which == $.FroalaEditor.KEYCODE.ENTER and editor.$el.atwho('isSelecting')
        return false
      return
    ), true
    return
  ).froalaEditor
    key: froala_editor_key
    toolbarBottom: true
    placeholderText: 'Add a comment...'
    toolbarButtons: [
      'bold'
      'italic'
      'underline'
      '|'
      'formatOL'
      'formatUL'
      '|'
      'quote'
    ]