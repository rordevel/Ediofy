require 'application_system_test_case'
require 'devise/test/integration_helpers'

class LinksTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in create(:user)
  end

  test 'creating link' do
    visit '/'
    page.find('.mobileNav').click
    click_link 'Share'
    click_link 'Share a Link'

    fill_in 'Title', with: 'Link title'
    fill_in 'URL', with: 'http://www.google.com'
    page.find('textarea[name="link[description]"]').fill_in with: 'Description'
    page.find('#token-input-ignored').fill_in with: "firsttag\n"
    page.find('#token-input-ignored').fill_in with: "secondtag\n"
    choose 'resource_private_no'
    click_button 'Upload'

    assert_text 'Link title'

    click_link 'Edit'
    fill_in 'Title', with: 'New link title'
    click_button 'Save'

    assert_text 'New link title'

    page.find('.best-image').click

    assert_button 'Google Search'
  end
end
