class TagBox

  constructor: (@el) ->
    @form = $('form', @el)
    @addButton = $('.add', @el)
    @input = $('input', @el).tokenInput "/autocomplete/tags", onAdd: @addTag, allowFreeTagging: true
    @list = $('ul.tags', @el)

    @addButton.click @showForm
    @el.on "click", ".destroy", @destroyTag

  showForm: =>
    @addButton.hide()
    @form.show()
    @form.submit @addTag

  addTag: (tag) =>
    @input.tokenInput "clear"
    @addList() if @list.size() == 0
    @list.append "<li class='tag'><a href='/media?complex_search=[#{tag.name}]'>#{tag.name}</a><a class='destroy' data-method='delete' data-remote='true' rel='nofollow' href='/media/#{@form.data('id')}/destroy_tag?tag=#{tag.name}'>×</a></li>"
    $.post this.form.attr("action"), tag: tag.name

  destroyTag: (e) =>
    $(e.currentTarget).closest('li').remove()
    if @list.children().size() == 0
      @list.replaceWith "<div class=no-tags><p>This item doesn't have any tags.</p></div>"
      @list = $('ul.tags', @el)

  addList: ->
    $('.no-tags').replaceWith "<ul class=tags></ul>"
    @list = $('ul.tags', @el)

jQuery ($) ->
  el = $('.tags-box')
  el.data "tags-box-reference", new TagBox(el)