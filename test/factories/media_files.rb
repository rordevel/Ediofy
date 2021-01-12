FactoryBot.define do
  factory :media_file do
    file { Rack::Test::UploadedFile.new(Rails.root.join('test/fixtures/files/medicine.jpg'), 'image/jpeg') }
    user
  end
end
