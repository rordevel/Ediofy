#= require active_admin/base
#= require active_admin/select2

$(document).ready ->
  $('select').each ->
    if $(this).attr('id') != ''
      $(this).select2()
    return
  return