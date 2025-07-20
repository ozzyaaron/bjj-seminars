FactoryBot.define do
  factory :seminar_player do
    association :seminar
    association :player
  end
end