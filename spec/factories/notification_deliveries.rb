FactoryBot.define do
  factory :notification_delivery do
    association :user
    association :seminar
    delivered_at { Time.current }
    
    trait :old do
      delivered_at { 100.days.ago }
    end
    
    trait :recent do
      delivered_at { 1.hour.ago }
    end
    
    trait :today do
      delivered_at { 10.minutes.ago }
    end
  end
end