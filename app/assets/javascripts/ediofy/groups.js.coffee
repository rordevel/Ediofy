$(document).ready ->
  $('.my-groups #my_group_sort_by').change ()->
    $.ajax(
      url: '/groups?my_groups=true&sort_by=' + $(@).val()
      method: "get"
      dataType: "script"
    )

  $('.discover-groups').find('#group_type, #group_sort_by').change ()->
    $.ajax(
      url: '/groups?type=' + $(".discover-groups #group_type").val() + '&sort_by=' + $(".discover-groups #group_sort_by").val()
      method: "get"
      dataType: "script"
    )

  $('.group-show').find('#content_type, #sort_by').change ()->

    vars = {}
    parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/g, (m, key, value) ->
      vars[key] = value
    )

    searchQuery = (vars["query"])

    $.ajax(
      url: '?type=' + $(".group-show #content_type").val() + '&sort_by=' + $(".group-show #sort_by").val() +  '&query=' + searchQuery + "" 
      method: "get"
      dataType: "script"
    )

  $('#joined-popover').popover(
    html:true
  ).on 'shown.bs.popover', ->
    $('.delete-group-btn').click ->
      elm = $(this)
      bootbox.confirm
        title: 'Delete '+ $(elm).data('type')
        message: 'All content saved to this ' + (elm).data('type').toLowerCase() + ' will still be available on Ediofy. Are you sure want to delete this '+  $(elm).data('type').toLowerCase() + '?'
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
    $('.report-group-btn').click ->
      elm = $(this)
      bootbox.confirm
        title: 'Report '+ $(elm).data('type')
        message: '<p>If you report a group your name will be kept anonymous and not shared with the owner of the group. </p>
                  <h5>Why are you reporting this group?</h5>
                  <form action="" class= "text-left">
                  <input type="radio" name="report" value="reason1"> Information shared by admin is inaccurate / negligent <br>
                  <input type="radio" name="report" value="reason2"> Sale or promotion of products or drugs<br>
                  <input type="radio" name="report" value="reason3"> Posting spam<br>
                  <input type="radio" name="report" value="reason4"> Violence or harmful behaviour<br>
                  <input type="radio" name="report" value="reason5"> Sexually explicit content<br>
                  <input type="radio" name="report" value="reason6"> Unauthorised use of group or company name or information<br>
                  <input type="radio" name="report" value="reason7"> Other<br>
                 </form> '
        buttons:
          confirm: label: 'Next'
        callback: (result) ->
          if result
            $.ajax
              url: $(elm).data('request-url')
              type: 'POST'
              data: { _method: 'GET', report: $('form input[name=report]:checked').val() }
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

  $('.modal-popover').popover(
    html:true
  )

  
 
  privacyFormat = (icon) ->
    originalOption = icon.element
    return $('<i class="fa ' + $(originalOption).data('icon') + '"></i>&nbsp; <b>' + icon.text + '</b><small class="text-muted">' + $(originalOption).data('additional') + '</small>');

  groupUsersFormat = (elem) ->
    $user = $(elem.element)

    selectedHtml =  '<span class="added-member"><i class="fa fa-check"></i> &nbsp; Added</span>'
    notSelectedHtml = '<span class="add-member"><i class="fa fa-plus"></i> &nbsp; Add member</span>'

    return $(
      '<div class="row user-card">' +
        '<div class="col-sm-12 col-md-12 wrapper">' +
          '<div class="image">' +
            '<img src=" ' + $user.data('image') + ' " class="img-circle" width="50" height="50" alt="123">' +
          '</div>' +

          '<div class="info">' +
            '<b>' + $user.data('name') + '</b>' +
            '<div class="text-muted">' + $user.data('title') + '</div>' +
          '</div>' +

          '<div class="role pull-right">' +
            if elem.selected then selectedHtml else notSelectedHtml +
          '</div>' +
        '</div>' +
      '</div>'
    )


  $('#group_user_ids').select2(
    width: "100%"
    theme: 'bootstrap'
    templateResult: groupUsersFormat
    allowHtml: true
  )

  $('#privacy_select').select2(
    width: "100%"
    theme: 'bootstrap'
    minimumResultsForSearch: -1
    templateResult: privacyFormat
    templateSelection: privacyFormat
    allowHtml: true
  )

  $('#group_id').select2(
    minimumResultsForSearch: -1,
    width: "200px"
  )

  #allow posting as group page if owner/admin
  $('#group_id').on 'select2:select', (e) ->
    data = e.params.data
    return

  $('#group-upload-link-images-holder').on 'click', ->
    $('#group_image_upload_button').trigger 'click'
    return

  $('#archived_c').change ->
    isit = $('#archived_c')[0].checked
    $.ajax(
      #url: '/groups?archived=' + isit
      url: '?archived=' + isit
      method: "get"
      dataType: "script"
    )

  $('#group_image_upload_button').change ->
    readImage this
    return

  readImage = (input) ->
    if input.files and input.files[0]
      reader = new FileReader

      reader.onload = (e) ->
        $('.group-pic').attr 'src', e.target.result
        $('.group-image').removeClass('hidden')
        $('.group-image img').show()
        $('#group_image_upload.noRecentView').hide()
        $('.remove-image').css 'display', 'block'
        return

      reader.readAsDataURL input.files[0]
    return

  $('.remove-image').click ->
    $('.group-image img').hide()
    $(this).hide()
    $('#group_image_upload.noRecentView').removeClass('hidden').show()
    $('#group_image_upload_button').val ''
    return

  # share template
  $groupId = $('#group_id')
  if ($('#resource_private_yes').prop('checked'))
    $groupId.prop('disabled', false)

  $('#resource_private_yes, #resource_private_no').change ->
    if $(@).attr('id') == 'resource_private_yes'
      $groupId.prop('disabled', false)
      $groupId.trigger('change')
    else
      $groupId.prop('disabled', true)
      $('.post_as_page').addClass('hidden')

  $groupId.change ->
    if ($('#able_groups').val().split(' ').includes($(@).val()))
      $('.post_as_page').removeClass('hidden')
    else
      $('.post_as_page').addClass('hidden')

  $('.search_members').on 'keyup', ->
    self = @
    $(@).parents('.modal-content').find('.user-card[data-name]').each () ->
      if $(@).data('name').toString().toLowerCase().includes($(self).val().toString().toLowerCase())
        $(@).show()
      else
        $(@).hide()
      return
      
  $('#group-announcements a').click (e) ->
    href = $(@).data('open')
    $(e.currentTarget).parents('.announc').addClass('hidden')
    $(href).removeClass('hidden')