require 'application_system_test_case'
require 'devise/test/integration_helpers'

class SearchTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:user, interest_list: ['Medicine'])
    @second_user = create(:user)
    @third_user = create(:user)
  end

  test 'perform a search' do
    setup_for_search

    visit '/'
    page.find('.mobileNav').click
    search = page.find('#q')
    search.fill_in with: '#firsttag'
    search.send_keys :enter

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
    assert_text '14 Results'
    assert_equal 12, page.all('#results-listing .items > div').length

    click_link 'Load more'

    assert_text 'Second page question'
    assert_text 'Another second page question'
    assert_text '14 Results'
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
  end

  test 'sort search results' do
    setup_for_sort

    visit '/'
    page.find('.mobileNav').click
    search = page.find('#q')
    search.fill_in with: "third user's"
    search.send_keys :enter

    assert_text "Search Results: third user's"

    within '#results-listing' do
      assert_equal 'Third user`s link', find('.post-cart:nth-child(1) a h6').text
      assert_equal "Third user's question", find('.post-cart:nth-child(2) a h6').text
      assert_equal "Third user's conversation", find('.post-cart:nth-child(3) a h6').text
    end

    page.find('.search-sort-by').select 'Top Rated'
    sleep 0.5

    within '#results-listing' do
      assert_equal "Third user's conversation", find('.post-cart:nth-child(1) a h6').text
      assert_equal "Third user's question", find('.post-cart:nth-child(2) a h6').text
      assert_equal 'Third user`s link', find('.post-cart:nth-child(3) a h6').text
    end

    page.find('.search-sort-by').select 'Most Popular'
    sleep 0.5

    within '#results-listing' do
      assert_equal "Third user's question", find('.post-cart:nth-child(1) a h6').text
      assert_equal 'Third user`s link', find('.post-cart:nth-child(2) a h6').text
      assert_equal "Third user's conversation", find('.post-cart:nth-child(3) a h6').text
    end

    page.find('.search-sort-by').select 'Trending'
    sleep 0.5

    within '#results-listing' do
      assert_equal "Third user's question", find('.post-cart:nth-child(1) a h6').text
      assert_equal "Third user's conversation", find('.post-cart:nth-child(2) a h6').text
      assert_equal 'Third user`s link', find('.post-cart:nth-child(3) a h6').text
    end
  end

  test 'search for people and groups' do
    setup_for_people_and_groups

    visit '/'
    page.find('.mobileNav').click
    search = page.find('#q')
    search.fill_in with: 'medicine'
    search.send_keys :enter

    assert_text 'Medicine Students Group'
    assert_text 'Nuclear Medicine'
    assert_text 'Matching Medicine User'
    assert_text 'Medicine User'
    assert_text 'Just Group'
    assert_equal 12, page.all('#people-results-listing .items > li').length

    click_link 'Load more'

    assert_text 'Second Page Medicine User'
    assert_equal 15, page.all('#people-results-listing .items > li').length
  end

  private

    def setup_for_search
      create(:question, title: 'Second page question', user: @third_user, tag_list: ['firsttag'])
      create(:question, title: 'Another second page question', user: @third_user, tag_list: ['firsttag'])
      create(:question, title: 'Fourth question', user: @third_user, tag_list: ['firsttag'])
      create(:question, title: 'Fifth question', user: @third_user, tag_list: ['firsttag'])
      create(:question, title: 'Sixth question', user: @third_user, tag_list: ['firsttag'])
      create(:question, title: 'Seventh question', user: @third_user, tag_list: ['firsttag'])
      create(:question, title: 'Eighth question', user: @third_user, tag_list: ['firsttag'])

      group = create(:group)
      group.users << @user
      group.users << @second_user
      group.conversations << create(:conversation, title: 'First conversation', user: @second_user, tag_list: ['firsttag'], group_exclusive: true)
      group.conversations << create(:conversation, title: 'Second conversation', user: @second_user, tag_list: ['secondtag'], group_exclusive: true)
      group.links << create(:link, title: 'First link', user: @second_user, tag_list: ['secondtag'], group_exclusive: true)
      group.media << create(:media, title: 'First media', user: @second_user, tag_list: ['firsttag'], group_exclusive: true)
      group.media.first.media_files.first.update(media_type: :audio)
      group.media << create(:media, title: 'Second media', user: @second_user, tag_list: ['secondtag'], group_exclusive: true)
      group.questions << create(:question, title: 'First question', user: @second_user, tag_list: ['firsttag', 'othertag'], group_exclusive: true)
      group.questions << create(:question, title: 'Second question', user: @second_user, tag_list: ['firsttag', 'secondtag', 'othertag'], group_exclusive: true)
      other_group = create(:group, title: 'Other group')
      other_group.conversations << create(:conversation, title: 'Third conversation', user: @third_user, tag_list: ['firsttag'], group_exclusive: true)
      create(:conversation, title: 'Fourth conversation', user: @third_user, tag_list: ['firsttag', 'secondtag'])
      create(:link, title: 'Second link', user: @third_user, tag_list: ['firsttag', 'secondtag'])
      create(:question, title: 'Third question', user: @third_user, tag_list: ['firsttag', 'secondtag'])

      sign_in @user
    end

    def setup_for_sort
      @conversation = create(:conversation, title: "Third user's conversation", user: @third_user, created_at: 25.seconds.ago)
      @question = create(:question, title: "Third user's question", user: @third_user, created_at: 23.seconds.ago)
      @link = create(:link, title: 'Third user`s link', user: @third_user, created_at: 20.seconds.ago)
      @visitor1 = create(:user)
      @visitor2 = create(:user)
      @visitor3 = create(:user)

      sign_in @visitor1
      visit "/conversations/#{@conversation.id}"
      vote_up
      visit "/questions/#{@question.id}"
      vote_up
      post_comment

      sign_out @visitor1
      visit '/'
      sign_in @visitor2
      visit "/conversations/#{@conversation.id}"
      vote_up
      visit "/questions/#{@question.id}"

      sign_out @visitor2
      visit '/'
      sign_in @visitor3
      visit "/questions/#{@question.id}"
      post_comment
      visit "/links/#{@link.id}"
      post_comment

      sign_out @visitor3
      visit '/'

      sign_in @user
    end

    def setup_for_people_and_groups
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
      group = create(:group, title: 'Just group')
      group.conversations << create(:conversation, title: 'Medicine conversation', group_exclusive: true)
      group = create(:group, title: 'Non-matching group')
      conversation = create(:conversation, title: 'Some conversation', tag_list: ['medicine'], group_exclusive: true)
      group.conversations << conversation
      conversation.update(tag_list: [])
      create(:user, full_name: 'Matching medicine user')
      create(:user, full_name: 'Medicine user')
      create(:user, full_name: 'Non-matching user', interest_list: ['Medicine'])

      sign_in @user
    end

    def vote_up
      page.find('.fa-thumbs-up').click
    end

    def post_comment
      page.find('#comment_comment_input .fr-toolbar').click
      page.find('#comment_comment_input div[contenteditable="true"]').click
      page.find('#comment_comment_input div[contenteditable="true"]').send_keys('Comment body')
      click_button 'Submit'
      sleep 0.1
    end
end
