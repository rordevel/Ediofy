require 'test_helper'

class MediaTest < ActiveSupport::TestCase
  test 'has many playlist_contents and playlists' do
    media = create(:media)

    playlist1 = Playlist.create
    playlist_content1 = media.playlist_contents.create(playlist: playlist1)

    playlist2 = Playlist.create
    playlist_content2 = media.playlist_contents.create(playlist: playlist2)

    assert_equal 2, media.playlist_contents.length
    assert_equal playlist_content1, media.playlist_contents[0]
    assert_equal playlist_content2, media.playlist_contents[1]

    assert_equal 2, media.playlists.length
    assert_equal playlist1, media.playlists[0]
    assert_equal playlist2, media.playlists[1]
  end
end
