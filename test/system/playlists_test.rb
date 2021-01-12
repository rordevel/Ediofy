require 'application_system_test_case'
require 'devise/test/integration_helpers'

class PlaylistsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    user = create(:user)
    sign_in user
    group = create(:group)
    group.users << user
    group.questions << create(:question, user: user)
    group.questions << create(:question, user: user, title: 'Another question')
  end

  test 'adding question to the new playlist' do
    visit '/'
    page.find('.mobileNav').click
    click_link 'Groups'
    click_link 'Group Title'
    click_link 'Question Title'

    page.find('.addToPlaylistBtn').click
    click_link 'Create new playlist'

    sleep 0.5
    fill_in 'Playlist name', with: 'Playlist name'
    fill_in 'Description', with: 'Playlist description'
    click_button 'Create'

    page.find('.mobileNav').click
    click_link 'Groups'
    click_link 'Group Title'
    click_link 'Another question'

    page.find('.addToPlaylistBtn').click
    page.find('#playlist_id').select 'Playlist name'
    click_button 'Add'

    assert_text 'Playlist name'
    assert_text 'Question Title'
    assert_text 'Another question'
  end
end
