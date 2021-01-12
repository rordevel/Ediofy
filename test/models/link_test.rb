require 'test_helper'

class LinkTest < ActiveSupport::TestCase
  test 'has many playlist_contents and playlists' do
    link = create(:link)

    playlist1 = Playlist.create
    playlist_content1 = link.playlist_contents.create(playlist: playlist1)

    playlist2 = Playlist.create
    playlist_content2 = link.playlist_contents.create(playlist: playlist2)

    assert_equal 2, link.playlist_contents.length
    assert_equal playlist_content1, link.playlist_contents[0]
    assert_equal playlist_content2, link.playlist_contents[1]

    assert_equal 2, link.playlists.length
    assert_equal playlist1, link.playlists[0]
    assert_equal playlist2, link.playlists[1]
  end
end
