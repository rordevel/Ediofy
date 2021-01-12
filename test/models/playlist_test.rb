require 'test_helper'

class PlaylistTest < ActiveSupport::TestCase
  test 'has many playlist_contents' do
    playlist = Playlist.new
    playlist_content1 = playlist.playlist_contents.new
    playlist_content2 = playlist.playlist_contents.new

    assert_equal 2, playlist.playlist_contents.length
    assert_equal playlist_content1, playlist.playlist_contents[0]
    assert_equal playlist_content2, playlist.playlist_contents[1]
  end

  test 'has many conversations through playlist_contents' do
    playlist = Playlist.create

    conversation1 = create(:conversation)
    playlist.playlist_contents.create(playable: conversation1)

    conversation2 = create(:conversation)
    playlist.playlist_contents.create(playable: conversation2)

    assert_equal 2, playlist.conversations.length
    assert_equal conversation1, playlist.conversations[0]
    assert_equal conversation2, playlist.conversations[1]
  end

  test 'has many links through playlist_contents' do
    playlist = Playlist.create

    link1 = create(:link)
    playlist.playlist_contents.create(playable: link1)

    link2 = create(:link)
    playlist.playlist_contents.create(playable: link2)

    assert_equal 2, playlist.links.length
    assert_equal link1, playlist.links[0]
    assert_equal link2, playlist.links[1]
  end

  test 'has many media through playlist_contents' do
    playlist = Playlist.create

    media1 = create(:media)
    playlist.playlist_contents.create(playable: media1)

    media2 = create(:media)
    playlist.playlist_contents.create(playable: media2)

    assert_equal 2, playlist.media.length
    assert_equal media1, playlist.media[0]
    assert_equal media2, playlist.media[1]
  end

  test 'has many questions through playlist_contents' do
    playlist = Playlist.create

    question1 = create(:question)
    playlist.playlist_contents.create(playable: question1)

    question2 = create(:question)
    playlist.playlist_contents.create(playable: question2)

    assert_equal 2, playlist.questions.length
    assert_equal question1, playlist.questions[0]
    assert_equal question2, playlist.questions[1]
  end
end
