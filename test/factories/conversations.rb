FactoryBot.define do
  factory :conversation do
    description { 'Description' }
    deleted { false }
    user

    sequence(:title) { |n| "Conversation title #{n}" }
  end
end
