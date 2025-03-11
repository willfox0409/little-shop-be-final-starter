class MerchantSerializer
  include JSONAPI::Serializer
  attributes :name, :coupons_count, :invoice_coupon_count

  attribute :item_count, if: Proc.new { |merchant, params|
    params && params[:count] == true
  } do |merchant|
    merchant.item_count
  end
end
