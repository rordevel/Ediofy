module PlaylistsHelper
  extend ActiveSupport::Concern

  included do
    helper_method :add_playable_to_playlist
  end

  def add_to_playlist
    playlist = Playlist.find(params[:playlist_id])

    playlist.playlist_contents.create(playable: @parent)

    redirect_to ediofy_playlist_path(playlist),
      notice: "#{@parent.class.name} has been added successfully!"
  end

  def find_playlist_from_params
    if params[:playlist].present?
      @playlist_id = params[:playlist]
    elsif request.referrer && request.referrer.include?('plcontenttitle')
      @playlist_id = request.referer.split('=').last.to_i
    end

    @playlist = Playlist.find(@playlist_id) if @playlist_id
  end

  def find_playlist_links(playable)
    return unless @playlist
    content = @playlist.content.find_by_playable_id(playable.id)
    @previous_playlist_content = @playlist.content.includes(:playable).find_by_position(content.position - 1)
    @next_playlist_content = @playlist.content.includes(:playable).find_by_position(content.position + 1)
  end
end
