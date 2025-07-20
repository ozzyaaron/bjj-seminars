FactoryBot.define do
  factory :notification_request do
    association :user
    active { true }
    
    # Default to city filter to satisfy at least one filter validation
    city { "San Francisco" }
    state { nil }
    player_ids { [] }
    
    trait :with_state do
      city { nil }
      state { "CA" }
    end
    
    trait :with_players do
      city { nil }
      state { nil }
      player_ids { [create(:player).id, create(:player).id] }
    end
    
    trait :with_all_filters do
      city { "San Francisco" }
      state { "CA" }
      player_ids { [create(:player).id] }
    end
    
    trait :inactive do
      active { false }
    end
  end
end