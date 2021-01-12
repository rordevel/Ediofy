jQuery ($) ->
  if ($form = $("form.media_collection")).length
    templates = {}
    $form.find('[data-template]').each ->
      $this = $(this)
      templates[$this.data('template')] = $.template $this.text()

    $form.find('a[data-add]').click (e) ->
      e.preventDefault()
      $this = $(this)
      setupHtmlInputs $.tmpl(templates[$this.data('add')], id: new Date().getTime()).insertBefore($this.parents('li').first())

    $form.on 'click', 'a[data-remove]', (e) ->
      e.preventDefault()
      $fields = $(this).parents("li.#{$(this).data('remove')}").first().remove()

    element = $('.media-uploader').get(0)
    if $(element).length
      uploader = new qq.FileUploader
        element: element
        action: $(element).data('url')
        allowedExtensions: ['pdf','jpg', 'jpeg', 'png', 'gif', 'mp4', 'mpg', 'm4v', 'mov', 'mkv', 'avi', 'ogg', 'wav', 'mp3', 'ogv', 'aac', 'wmv' ]
        uploadButtonText: 'Select media to upload'
        forceMultipart: true
        onSubmit: (id, fileName) ->
          uploader.setParams
            authenticity_token: $("input[name='authenticity_token']").attr("value")