require 'test_helper'

class PlaylistContentTest < ActiveSupport::TestCase
  test 'belongs to playlist' do
    playlist = Playlist.new
    playlist_content = PlaylistContent.new(playlist: playlist)

    assert_equal playlist, playlist_content.playlist
  end

  test 'can belong to conversation, link, media or question' do
    conversation = Conversation.new
    playlist_content1 = PlaylistContent.new(playable: conversation)

    link = Link.new
    playlist_content2 = PlaylistContent.new(playable: link)

    media = Media.new
    playlist_content3 = PlaylistContent.new(playable: media)

    question = Question.new
    playlist_content4 = PlaylistContent.new(playable: question)

    assert_equal conversation, playlist_content1.playable
    assert_equal link, playlist_content2.playable
    assert_equal media, playlist_content3.playable
    assert_equal question, playlist_content4.playable
  end
end
