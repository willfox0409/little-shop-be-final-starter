class CouponSerializer
  include JSONAPI::Serializer
  attributes :id, :name, :code, :discount_value, :discount_type, :active, :merchant_id, :usage_count
end
