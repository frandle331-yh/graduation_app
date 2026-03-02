FactoryBot.define do
  factory :housework_log do
    association :user
    title        { Faker::Lorem.word }
    category     { :cleaning }
    performed_on { Time.zone.today }
    minutes      { 30 }
    memo         { nil }
    household    { nil }
  end
end
