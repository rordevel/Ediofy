require 'application_system_test_case'
require 'devise/test/integration_helpers'

class MediaTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in create(:user)
  end

  test 'adding photo' do
    visit '/'
    page.find('.mobileNav').click
    click_link 'Share'
    click_link 'Upload Media'

    page.find('input[name="media[title]"]').fill_in with: 'Title'
    fill_in 'Description', with: 'Description'
    path = File.expand_path('test/fixtures/files/medicine.jpg')
    attach_file('media[media_files_attributes][0][file]', path, make_visible: true)
    click_button 'Publish'

    assert_text 'Title'
  end
end
