$('document').ready ->
  $('.content-search-filters select').on 'change', ->
    $(this).parents('.content-search-filters').submit()
