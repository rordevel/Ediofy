$ ->
  video_file_id = $('#video_file_id')
  if video_file_id.length > 0
    App.video_file = App.cable.subscriptions.create { 
      channel: "VideoChannel",
      video_file_id: video_file_id.val() 
    },
    connected: ->
      console.log 'cable connected'
      if video_file[video_file_id.val()]['processed']
        App.video_file.touch_media_file()
    disconnected: ->
      # Called when the subscription has been terminated by the server
      console.log 'cable disconnected'
    received: (video_file) ->
      if video_file.hasOwnProperty('processed')
        if video_file['processed']
          if $('.video-sec').length > 0
            $('.video-sec').html("<video controls='controls' loop='loop' src="+video_file['video_url_mp4']+" width='100%' height='100%'></video>")
          else if $('.que-slider').length > 0
            $('.que-slider').find('img.video-not-encoded').replaceWith("<video controls='controls' loop='loop' src="+video_file['video_url_mp4']+" width='100%' height='100%'></video>")
            $('.inner-slider').find('img.video-not-encoded-thumb').attr('src', video_file['video_thumb_url'])
    touch_media_file: () ->
      @perform 'touch_media_file', id: video_file_id.val()