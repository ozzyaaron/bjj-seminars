FactoryBot.define do
  factory :team do
    name { Faker::Team.name }
    description { Faker::Lorem.paragraph }
    country { 'US' }
  end
end