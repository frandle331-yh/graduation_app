FactoryBot.define do
  factory :household_member do
    association :household
    association :user
    role      { :owner }
    joined_at { Time.current }
  end
end
