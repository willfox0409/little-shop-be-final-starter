FactoryBot.define do
  factory :merchant do
    id { Faker::Number.number(digits: 3) }
    name { Faker::Company.name }
    created_at { Time.current }
  end
end
