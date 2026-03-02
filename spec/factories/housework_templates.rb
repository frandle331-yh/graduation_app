FactoryBot.define do
  factory :housework_template do
    association :user
    title    { Faker::Lorem.word }
    category { :cleaning }
    minutes  { 30 }
    position { 0 }
    household { nil }
  end
end
