FactoryBot.define do
  factory :coupon do
  association :merchant
    name { Faker::Commerce.promotion_code }
    code { Faker::Alphanumeric.alphanumeric(number: 6).upcase }
    discount_calue { rand(5...50) }
    discount_type { ["dollar", "percent"].sample }
    active { ["true", "false"].sample }
    created_at { Time.current }
    updated_at { Time.current }
  end
end