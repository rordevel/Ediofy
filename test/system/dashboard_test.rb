require 'application_system_test_case'
require 'devise/test/integration_helpers'

class DashboardTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:user, interest_list: ['Medicine'])

    # Related Content
    @second_user = create(:user)
    @third_user = create(:user)
    group = create(:group)
    group.users << @user
    group.users << @second_user
    create(:question, title: 'Second page question', user: @third_user, tag_list: ['medicine'])
    create(:question, title: 'Another second page question', user: @third_user, tag_list: ['medicine'])
    create(:question, title: 'Fourth question', user: @third_user, tag_list: ['medicine'])
    create(:question, title: 'Fifth question', user: @third_user, tag_list: ['medicine'])
    create(:question, title: 'Sixth question', user: @third_user, tag_list: ['medicine'])
    create(:question, title: 'Seventh question', user: @third_user, tag_list: ['medicine'])
    create(:question, title: 'Eighth question', user: @third_user, tag_list: ['medicine'])
    group = create(:group, title: 'Group with a lot of content')
    group.users << @user
    group.users << @second_user
    group.conversations << create(:conversation, title: 'First conversation', user: @second_user, tag_list: ['medicine'], group_exclusive: true)
    group.conversations << create(:conversation, title: 'Second conversation', user: @second_user, tag_list: ['secondtag'], group_exclusive: true)
    group.links << create(:link, title: 'First link', user: @second_user, tag_list: ['secondtag'], group_exclusive: true)
    group.media << create(:media, title: 'First media', user: @second_user, tag_list: ['medicine'], group_exclusive: true)
    group.media.first.media_files.first.update(media_type: :audio)
    group.media << create(:media, title: 'Second media', user: @second_user, tag_list: ['secondtag'], group_exclusive: true)
    group.questions << create(:question, title: 'First question', user: @second_user, tag_list: ['medicine', 'othertag'], group_exclusive: true)
    group.questions << create(:question, title: 'Second question', user: @second_user, tag_list: ['medicine', 'secondtag', 'othertag'], group_exclusive: true)
    other_group = create(:group, title: 'Other group')
    other_group.conversations << create(:conversation, title: 'Third conversation', user: @third_user, tag_list: ['medicine'], group_exclusive: true)
    create(:conversation, title: 'Fourth conversation', user: @third_user, tag_list: ['medicine', 'secondtag'])
    create(:link, title: 'Second link', user: @third_user, tag_list: ['medicine', 'secondtag'])
    create(:question, title: 'Third question', user: @third_user, tag_list: ['medicine', 'secondtag'])

    # Related People & Groups
    create(:user, full_name: 'Second page medicine user')
    create(:user, full_name: 'Medicine user')
    create(:user, full_name: 'Medicine user')
    create(:user, full_name: 'Medicine user')
    create(:user, full_name: 'Medicine user')
    create(:user, full_name: 'Medicine user')
    create(:user, full_name: 'Medicine user')
    create(:user, full_name: 'Medicine user')
    create(:user, full_name: 'Medicine user')
    create(:user, full_name: 'Medicine user')
    create(:group, title: 'Medicine students group')
    create(:group, title: 'Neurosurgery group')
    create(:group, title: 'Nuclear Medicine')
    create(:group, title: 'Molecular biology students group')
    create(:user, full_name: 'Matching medicine user')
    create(:user, full_name: 'Medicine user')
    create(:user, full_name: 'Non-matching user', interest_list: ['Medicine'])

    sign_in @user
  end

  test 'opening the dashboard' do
    visit '/'

    assert_text "You don't have any viewing history yet."
    page.find('.get-started').click

    # Related Content
    assert_text 'First conversation'
    assert_text 'First media'
    assert_text 'First question'
    assert_text 'Second question'
    assert_text 'Fourth conversation'
    assert_text 'Second link'
    assert_text 'Third question'
    assert_text 'Fourth question'
    assert_text 'Fifth question'
    assert_text 'Sixth question'
    assert_text 'Seventh question'
    assert_text 'Eighth question'
    assert_equal 12, page.all('#results-listing .items > div').length
    page.all(:xpath, '//a[.="Load more"]')[0].click
    assert_text 'Second page question'
    assert_text 'Another second page question'
    assert_equal 14, page.all('#results-listing .items > div').length
    page.find('.search-content-type').select 'Images'
    assert_text 'No matching content found.'
    page.find('.search-content-type').select 'Videos'
    assert_text 'No matching content found.'
    page.find('.search-content-type').select 'Audio'
    assert_text 'First media'
    page.find('.search-content-type').select 'Questions'
    assert_text 'First question'
    assert_text 'Second question'
    assert_text 'Third question'
    assert_text 'Fourth question'
    assert_text 'Fifth question'
    assert_text 'Sixth question'
    assert_text 'Seventh question'
    assert_text 'Eighth question'
    assert_text 'Second page question'
    assert_text 'Another second page question'
    page.find('.search-content-type').select 'Conversations'
    assert_text 'First conversation'
    assert_text 'Fourth conversation'
    page.find('.search-content-type').select 'PDFs'
    assert_text 'No matching content found.'

    # Related People & Groups
    assert_text 'Medicine Students Group'
    assert_text 'Nuclear Medicine'
    assert_text 'Matching Medicine User'
    assert_text 'Medicine User'
    assert_equal 12, page.all('#people-results-listing .items > li').length
    click_link 'Load more'
    assert_text 'Second Page Medicine User'
    assert_text 'Group With A Lot Of Content'
    assert_equal 16, page.all('#people-results-listing .items > li').length

    # Recently Viewed
    page.find('.search-content-type').select 'All Content'
    click_link 'Third question'
    visit '/'
    click_link 'Second link'
    visit '/'
    click_link 'First media'
    visit '/'
    click_link 'First conversation'
    visit '/'
    within '.recentlyViewedTop > .container > .row' do
      assert_equal 'First conversation', find('.post-cart:nth-child(1) a h6').text
      assert_equal 'First media', find('.post-cart:nth-child(2) a h6').text
      assert_equal 'Second link', find('.post-cart:nth-child(3) a h6').text
      assert_equal 'Third question', find('.post-cart:nth-child(4) a h6').text
    end
  end
end
