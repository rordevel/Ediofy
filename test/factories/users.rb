FactoryBot.define do
  factory :user do
    password { 'password' }
    password_confirmation { 'password' }
    username { 'username' }
    full_name { 'Testing User' }
    confirmed_at { Time.now }
    ediofy_terms_accepted { true }
    profile_completed { true }
    interests_selected { true }
    follows_selected { true }

    sequence(:email) { |n| "user#{n}@example.com" }

    factory :followee do
      email { 'followee@example.com' }
      password { 'password' }
      password_confirmation { 'password' }
      username { 'followee' }
      full_name { 'Followee User' }
    end

    trait :with_followee do
      after(:create) do |user|
        user.follow create(:followee)
      end
    end
  end
end
