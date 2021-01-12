require 'application_system_test_case'
require 'devise/test/integration_helpers'

class AdminTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    create :admin_user

    user1 = create(:user)
    user2 = create(:user)
    user3 = create(:user)

    question = create :question, body: 'First question'
    question.vote_up user1
    question.vote_down user2
    question.vote_down user3

    question = create :question, body: 'Second question'
    question.vote_up user1

    media = create :media, title: 'Media title'
    media.vote_down user1

    conversation = create :conversation
    conversation.vote_down user1

    link = create :link
    link.vote_down user1
  end

  test 'checking ratings' do
    visit '/admin'
    fill_in 'Email', with: 'admin@example.com'
    fill_in 'Password', with: 'password'
    click_button 'Login'
    page.find(:link, text: 'Reports').hover
    click_link 'Ratings'

    assert_equal 2, page.all('table tbody tr').length

    within 'table tbody tr:nth-child(1)' do
      assert_equal 'Media', find('td:nth-child(2)').text
      assert_equal 'Media title', find('td:nth-child(3)').text
      assert_equal '1', find('td:nth-child(6)').text
    end

    within 'table tbody tr:nth-child(2)' do
      assert_equal 'Question', find('td:nth-child(2)').text
      assert_equal 'First question', find('td:nth-child(3)').text
      assert_equal '2', find('td:nth-child(6)').text
    end

    fill_in 'Content Title', with: 'Media'
    click_button 'Filter'

    assert_equal 1, page.all('table tbody tr').length

    within 'table tbody tr:nth-child(1)' do
      assert_equal 'Media', find('td:nth-child(2)').text
      assert_equal 'Media title', find('td:nth-child(3)').text
      assert_equal '1', find('td:nth-child(6)').text
    end
  end
end
