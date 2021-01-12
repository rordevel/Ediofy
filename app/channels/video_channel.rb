class VideoChannel < ApplicationCable::Channel
  # Called when the consumer has successfully
  # become a subscriber to this channel.
  def subscribed
    stream_from "media_file_#{params[:video_file_id]}_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def touch_media_file(data)
    media_file = MediaFile.find(data['id'])
    if media_file.video? && media_file.processed
      ActionCable.server.broadcast("media_file_#{media_file.id}_channel", {
        id: media_file.id,
        processed: media_file.processed,
        video_url_mp4: media_file.video_url_mp4,
        video_thumb_url: media_file.video_thumb_url
      })
      NotificationMailer.media_processed(media_file.media.user, media_file.media.id).deliver_later
    end
  end

end