$(document).on 'ready', ->
  $(".getdata").on 'click', ->
    id = $(this).attr('id')
    $.ajax
      url: '/links/' + id + '/' + 'update_cpd'
      type: 'POST'
      data: { media_file_id: id }
      success: (result) ->
        console.log 'success'
        return
