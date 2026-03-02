FactoryBot.define do
  factory :household do
    association :creator, factory: :user
    name            { Faker::Address.community }
    invitation_code { SecureRandom.alphanumeric(8) }
  end
end
