FactoryBot.define do
  factory :media do
    description { 'Media description' }
    user
    media_files { [create(:media_file)] }

    sequence(:title) { |n| "Media title #{n}" }
  end
end
