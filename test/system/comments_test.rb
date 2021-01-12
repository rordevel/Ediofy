require 'application_system_test_case'
require 'devise/test/integration_helpers'

class CommentsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    user = create(:user)
    sign_in user
    group = create(:group)
    group.users << user
    group.questions << create(:question, user: user)
  end

  test 'writing comments' do
    visit '/'
    page.find('.mobileNav').click
    click_link 'Groups'
    click_link 'Group Title'
    click_link 'Question Title'

    page.find('#comment_comment_input .fr-toolbar').click
    page.find('#comment_comment_input div[contenteditable="true"]').click
    page.find('#comment_comment_input div[contenteditable="true"]').send_keys('Comment body to be removed')
    click_button 'Cancel'

    assert_css '#comment_comment_input div[contenteditable="true"]', text: ''

    page.find('#comment_comment_input div[contenteditable="true"]').click
    page.find('#comment_comment_input div[contenteditable="true"]').send_keys('Comment body')
    click_button 'Submit'

    click_link 'Reply'
    sleep 0.2
    page.all('#comment_comment_input .fr-toolbar')[1].click
    page.all('#comment_comment_input div[contenteditable="true"]')[1].click
    page.all('#comment_comment_input div[contenteditable="true"]')[1].send_keys('Comment body to be removed')
    page.all(:xpath, '//button[.="Cancel"]')[1].click
    click_link 'Reply'
    sleep 0.2
    page.all('#comment_comment_input div[contenteditable="true"]')[1].click
    page.all('#comment_comment_input div[contenteditable="true"]')[1].send_keys('Another comment')
    page.all(:xpath, '//button[.="Submit"]')[1].click

    assert_text 'Comment body'
    assert_text 'Another comment'

    visit current_path

    assert_text 'Comment body'
    assert_text 'Another comment'
  end
end
