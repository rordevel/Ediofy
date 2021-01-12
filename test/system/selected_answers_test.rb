require 'application_system_test_case'
require 'devise/test/integration_helpers'

class SelectedAnswersTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    user = create(:user)
    sign_in user
    group = create(:group)
    group.users << user
    group.questions << create(:question, user: user)
  end

  test 'choosing an answer' do
    visit '/'
    page.find('.mobileNav').click
    click_link 'Groups'
    click_link 'Group Title'
    click_link 'Question Title'

    click_link 'Answer 1'

    assert page.find('#exam-question-answer .incorrect p').text == 'Answer 1'
    assert page.find('#exam-question-answer .correct p').text == 'Answer 2'
  end
end
