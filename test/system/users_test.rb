require 'application_system_test_case'
require 'support/mailer_helper'

class UsersTest < ApplicationSystemTestCase
  include MailerHelper

  setup do
    @user = create(:user)
    create(:interest)
  end

  test 'signing up' do
    visit '/'
    # Ambigous match
    # click_link 'Start learning'
    page.find(:xpath, '(//a[.="Start learning"])[1]').click
    sleep 1
    click_link 'Sign up now'

    fill_in 'Email', with: 'user@domain.com'
    fill_in 'Password', with: 'password'
    fill_in 'Password Confirmation', with: 'password'
    check 'By creating an account you agree to our terms & conditions and privacy policy'
    click_button 'Create account'

    assert_text "You're almost done!"
    assert_text 'Please check your email to verify your account.'

    confirmation_url = extract_confirmation_url_from last_email
    visit confirmation_url

    assert_text 'Congratulations!'
    assert_text 'Welcome to ediofy! You have successfully created your account.'

    click_link 'Get Started'

    fill_in 'Email', with: 'user@domain.com'
    fill_in 'Password', with: 'password'
    click_button 'Start learning'

    assert_text 'My Profile'

    fill_in 'Full Name', with: 'User Name'
    select 'Mr', from: 'Title'
    fill_in 'Location', with: 'Neverland'
    click_button 'Next'

    assert_text 'My Interests'

    choose_interest 'Medicine'
    click_button 'Next'

    # TODO Test following
    # follow_user @user
    click_button 'Next'

    assert_text 'User Name'
  end

  private

    def choose_interest(name)
      page.find('p', text: name).click
    end

    def follow_user(user)
      # Need to scroll to see checkmark
      2.times do
        page.find("label[for='user_#{user.id}'] i.fa-check").click
      end
    end
end
