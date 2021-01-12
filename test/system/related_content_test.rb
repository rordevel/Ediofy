require 'application_system_test_case'
require 'devise/test/integration_helpers'

class RelatedContentTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    user = create(:user)
    sign_in user
    second_user = create(:user)
    third_user = create(:user)
    group = create(:group)
    group.users << user
    group.users << second_user
    group.conversations << create(:conversation, title: 'First conversation', user: second_user, tag_list: ['firsttag'], group_exclusive: true)
    group.conversations << create(:conversation, title: 'Second conversation', user: second_user, tag_list: ['secondtag'], group_exclusive: true)
    group.links << create(:link, title: 'First link', user: second_user, tag_list: ['firsttag'], group_exclusive: true)
    group.links << create(:link, title: 'Second link', user: second_user, tag_list: ['secondtag'], group_exclusive: true)
    group.media << create(:media, title: 'First media', user: second_user, tag_list: ['firsttag'], group_exclusive: true)
    group.media << create(:media, title: 'Second media', user: second_user, tag_list: ['secondtag'], group_exclusive: true)
    group.questions << create(:question, title: 'First question', user: second_user, tag_list: ['firsttag', 'othertag'], group_exclusive: true)
    group.questions << create(:question, title: 'Second question', user: second_user, tag_list: ['firsttag', 'secondtag', 'othertag'], group_exclusive: true)
    other_group = create(:group, title: 'Other group')
    other_group.conversations << create(:conversation, title: 'Third conversation', user: third_user, tag_list: ['firsttag'], group_exclusive: true)
    other_group.links << create(:link, title: 'Third link', user: third_user, tag_list: ['firsttag'], group_exclusive: true)
    other_group.questions << create(:question, title: 'Third question', user: third_user, tag_list: ['firsttag'], group_exclusive: true)
    create(:conversation, title: 'Fourth conversation', user: third_user, tag_list: ['firsttag', 'secondtag'])
    create(:link, title: 'Fourth link', user: third_user, tag_list: ['firsttag', 'secondtag'])
    create(:media, title: 'Fourth media', user: third_user, tag_list: ['firsttag', 'secondtag'])
    create(:question, title: 'Fourth question', user: third_user, tag_list: ['firsttag', 'secondtag'])
  end

  test 'showing related content' do
    visit '/'
    page.find('.mobileNav').click
    click_link 'Groups'
    click_link 'Group Title'

    click_link 'First question'
    sleep 1

    assert_text 'Second question'
    assert_text 'Fourth question'

    click_link 'Conversations'
    sleep 1

    assert_text 'First conversation'
    assert_text 'Fourth conversation'

    click_link 'Media'
    sleep 1

    assert_text 'First media'
    assert_text 'Fourth media'
    assert_text 'First link'
    assert_text 'Fourth link'

    page.find('.mobileNav').click
    click_link 'Groups'
    click_link 'Group Title'

    click_link 'First conversation'
    sleep 1

    assert_text 'Fourth conversation'

    click_link 'Questions'
    sleep 1

    assert_text 'First question'
    assert_text 'Second question'
    assert_text 'Fourth question'

    page.find('.mobileNav').click
    click_link 'Groups'
    click_link 'Group Title'

    click_link 'First link'
    sleep 1

    assert_text 'First media'
    assert_text 'Fourth media'
    assert_text 'Fourth link'

    page.find('.mobileNav').click
    click_link 'Groups'
    click_link 'Group Title'

    click_link 'First media'
    sleep 1

    assert_text 'Fourth media'
    assert_text 'First link'
    assert_text 'Fourth link'
  end
end
