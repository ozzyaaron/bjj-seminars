FactoryBot.define do
  factory :player do
    team
    name { Faker::Name.name }
    belt_rank { %w[white blue purple brown black].sample }
    biography { Faker::Lorem.paragraph(sentence_count: 3) }
  end
end