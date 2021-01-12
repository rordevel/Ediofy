FactoryBot.define do
  factory :link do
    url { 'http://www.google.com' }
    description { 'Link description' }
    user

    sequence(:title) { |n| "Link title #{n}" }
  end
end
