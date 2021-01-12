require 'application_system_test_case'
require 'devise/test/integration_helpers'

class ConversationsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    user = create(:user)
    sign_in user
    group = create(:group)
    group.users << user
  end

  test 'starting conversation' do
    visit '/'
    page.find('.mobileNav').click
    click_link 'Groups'
    click_link 'Group Title'
    click_link 'Start a conversation'

    fill_in 'Title', with: 'Conversation Title'
    page.find('textarea[name="conversation[description]"]').fill_in with: 'Description'
    page.find('#token-input-ignored').fill_in with: "firsttag\n"
    page.find('#token-input-ignored').fill_in with: "secondtag\n"
    click_button 'Post'

    assert_text 'Conversation Title'

    click_link 'Edit conversation'
    fill_in 'Title', with: 'New conversation title'
    click_button 'Save'

    page.find('.mobileNav').click
    click_link 'Groups'
    click_link 'Group Title'

    assert_text 'New conversation title'
  end
end
