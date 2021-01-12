#= require_tree ./user



jQuery ($) ->
  $(".plot").each ->
    $plot = $(this)
    $.plot($plot, $plot.data('plot'), $plot.data('plot-options'))

  $progress = $('#level-progress')
  percent = parseFloat $progress.data 'progress'
  $progress.find('.progress-bar').width percent + '%'


    
  $("td.comment").blur ->
    cpd_time_id = $(this).parent().data('id')
    comment = $(this).text()

    first_i = 0
    last_i = comment.length

    if comment[0] == '\n'
      first_i = first_i + 1

    if comment[comment.length - 1] == '\n'
      last_i = last_i - 1

    comment = comment.substring(first_i, last_i)

    if comment.length > 250
      return

    $.ajax
      url: '/users/update_cpd_comment'
      type: 'POST'
      data: { id: cpd_time_id, comment: comment}
      success: (result) ->
        return
