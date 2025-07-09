FactoryBot.define do
  factory :player do
    team
    name { Faker::Name.name }
    nationality { Faker::Address.country }
    bio { Faker::Lorem.paragraph(sentence_count: 3) }
  end
end