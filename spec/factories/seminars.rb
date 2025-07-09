FactoryBot.define do
  factory :seminar do
    user
    title { Faker::Lorem.sentence(word_count: 3) }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    starts_at { Faker::Date.between(from: 1.week.from_now, to: 1.month.from_now) }
    ends_at { starts_at + 2.hours if starts_at }
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    state { 'CA' }
    zip_code { Faker::Address.zip_code }
    country { 'US' }
    
    trait :past do
      starts_at { Faker::Date.between(from: 6.months.ago, to: 1.day.ago) }
      ends_at { starts_at + 2.hours if starts_at }
    end
    
    trait :future do
      starts_at { Faker::Date.between(from: 1.day.from_now, to: 6.months.from_now) }
      ends_at { starts_at + 2.hours if starts_at }
    end
    
    trait :with_images do
      after(:build) do |seminar|
        2.times do
          seminar.images.attach(
            io: StringIO.new("fake image content"),
            filename: "test_image.jpg",
            content_type: "image/jpeg"
          )
        end
      end
    end
    
    trait :with_players do
      after(:create) do |seminar|
        team = create(:team)
        players = create_list(:player, 2, team: team)
        seminar.players = players
      end
    end
  end
end