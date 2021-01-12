FactoryBot.define do
  factory :interest do
    name { 'Medicine' }
    image { File.open(Rails.root.join('test/fixtures/files/medicine.jpg')) }
  end
end
