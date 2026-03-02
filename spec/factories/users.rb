FactoryBot.define do
  factory :user do
    nickname { Faker::Name.first_name }
    email    { Faker::Internet.unique.email }
    password { "password123" }

    trait :withdrawn do
      withdrawn_at { 1.day.ago }
    end

    trait :without_household do
      # デフォルトのまま（世帯なし）
    end
  end
end
