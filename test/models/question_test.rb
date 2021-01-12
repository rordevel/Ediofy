require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  test 'has many playlist_contents and playlists' do
    question = create(:question)

    playlist1 = Playlist.create
    playlist_content1 = question.playlist_contents.create(playlist: playlist1)

    playlist2 = Playlist.create
    playlist_content2 = question.playlist_contents.create(playlist: playlist2)

    assert_equal 2, question.playlist_contents.length
    assert_equal playlist_content1, question.playlist_contents[0]
    assert_equal playlist_content2, question.playlist_contents[1]

    assert_equal 2, question.playlists.length
    assert_equal playlist1, question.playlists[0]
    assert_equal playlist2, question.playlists[1]
  end
end
