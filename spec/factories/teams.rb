FactoryBot.define do
  factory :team do
    name { Faker::Team.name }
    description { Faker::Lorem.paragraph }
    location { Faker::Address.city }
    website { Faker::Internet.url }
    
    trait :with_members do
      after(:create) do |team|
        create_list(:user, 3, team: team)
      end
    end
  end
end