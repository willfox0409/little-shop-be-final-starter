FactoryBot.define do
  factory :customer do
    id { Faker::Number.number(digits: 3) }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
  end
end