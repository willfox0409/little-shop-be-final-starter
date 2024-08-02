FactoryBot.define do
  factory :merchant do
    name { Faker::Company.name }
    created_at { Time.current }
  end
end
