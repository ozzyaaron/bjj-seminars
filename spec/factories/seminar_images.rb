FactoryBot.define do
  factory :seminar_image do
    association :seminar
    sequence(:position) { |n| n }
    primary { false }
    
    after(:build) do |seminar_image|
      seminar_image.image.attach(
        io: StringIO.new("fake image data"),
        filename: "test_image.jpg",
        content_type: "image/jpeg"
      )
    end
    
    trait :primary do
      primary { true }
      position { 1 }
    end
  end
end