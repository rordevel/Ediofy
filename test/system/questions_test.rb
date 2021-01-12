require 'application_system_test_case'
require 'devise/test/integration_helpers'

class QuestionsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    user = create(:user)
    sign_in user
    group = create(:group)
    group.users << user
  end

  test 'posting a question' do
    visit '/'
    page.find('.mobileNav').click
    click_link 'Groups'
    click_link 'Group Title'
    click_link 'Write a question'

    page.find('input[name="question[title]"]').fill_in with: 'Question Title'
    page.find('textarea[name="question[body]"]').fill_in with: 'Question text'
    page.find('#add-answer').click
    page.find('textarea[name="question[answers_attributes][0][body]"]').fill_in with: 'Answer 1'
    page.find('textarea[name="question[answers_attributes][1][body]"]').fill_in with: 'Answer 2'
    page.find('textarea[name="question[answers_attributes][2][body]"]').fill_in with: 'Answer 3'
    page.all('.nested_question_answers input[name="correct"]')[2].click
    # TODO Input question explanation
    # page.find('textarea[name="question[explanation]"]').fill_in with: 'Question explanation'
    page.find(:xpath, '//a[contains(., "Add another reference")]').click
    page.find('input[name="question[references_attributes][0][url]"]').fill_in with: 'http://www.google.com'
    page.find('input[name="question[references_attributes][0][title]"]').fill_in with: 'Google'
    page.find('input[name="question[references_attributes][1][url]"]').fill_in with: 'http://www.apple.com'
    page.find('input[name="question[references_attributes][1][title]"]').fill_in with: 'Apple'
    page.find('#token-input-ignored').fill_in with: "firsttag\n"
    page.find('#token-input-ignored').fill_in with: "secondtag\n"
    click_button 'Upload'

    assert_text 'Question Title'

    click_link 'Edit question'
    page.find('input[name="question[title]"]').fill_in with: 'New question title'
    click_button 'Save'

    page.find('.mobileNav').click
    click_link 'Groups'
    click_link 'Group Title'

    assert_text 'New question title'
  end
end
