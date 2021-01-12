require 'test_helper'

class ConversationTest < ActiveSupport::TestCase
  test 'has many playlist_contents and playlists' do
    conversation = create(:conversation)

    playlist1 = Playlist.create
    playlist_content1 = conversation.playlist_contents.create(playlist: playlist1)

    playlist2 = Playlist.create
    playlist_content2 = conversation.playlist_contents.create(playlist: playlist2)

    assert_equal 2, conversation.playlist_contents.length
    assert_equal playlist_content1, conversation.playlist_contents[0]
    assert_equal playlist_content2, conversation.playlist_contents[1]

    assert_equal 2, conversation.playlists.length
    assert_equal playlist1, conversation.playlists[0]
    assert_equal playlist2, conversation.playlists[1]
  end
end
