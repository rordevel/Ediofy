require 'application_system_test_case'
require 'devise/test/integration_helpers'

class GroupsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:user, :with_followee)
    sign_in @user
    @user_to_invite = create(:user, full_name: 'User to invite')
  end

  test 'creating group and inviting member' do
    visit '/'
    page.find('.mobileNav').click
    click_link 'Groups'

    # TODO Test clicking on Create Group link and agreeing
    # page.find('a', text: 'Create Group').click
    # click_link 'Agree'

    visit '/groups/new'

    # TODO Test attaching image
    # attach_file 'group[image]', Rails.root.join('test/fixtures/files/medicine.jpg')
    # or
    # page.find('input[name="group[image]"]').set(Rails.root.join('test/fixtures/files/medicine.jpg'))
    fill_in 'Name your group', with: 'Group Name'
    fill_in 'Description', with: 'Group Description'
    fill_in 'URL', with: 'http://www.google.com'
    select 'Followee User', from: 'Add members by name or email'
    click_button 'Create'

    assert_text 'Group Name'

    page.find('.green-link').click
    click_link 'Add member'

    sign_in @user_to_invite
    visit '/'
    page.find('.myAccount').hover
    click_link 'Notifications'
    click_link 'Accept'

    visit '/'
    page.find('.mobileNav').click
    click_link 'Groups'
    click_link 'Group Name'

    assert_text 'Members • 2'
  end
end
