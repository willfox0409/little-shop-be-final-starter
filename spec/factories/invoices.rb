FactoryBot.define do
  factory :invoice do
    id { Faker::Number.number(digits: 3) }
    status { "shipped" }
    customer
    merchant
  end
end