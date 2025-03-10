class Api::V1::Merchants::CouponsController < ApplicationController
    before_action :merchant_setup

  def index
    coupons = @merchant.coupons
    render json: CouponSerializer.new(coupons)
  end

  def show
    coupon = @merchant.coupons.find(params[:id])
    render json: CouponSerializer.new(coupon)
  end

  def create
    coupon = @merchant.coupons.create!(coupon_params) 
    render json: CouponSerializer.new(coupon), status: :created
  end

  def update
    coupon = @merchant.coupons.find(params[:id])
    
    if params[:coupon].key?(:active)
      coupon.toggle_active!
    end
    coupon.update!(coupon_params)

    render json: CouponSerializer.new(coupon)
  end

  private

  def coupon_params
    params.require(:coupon).permit(:name, :code, :discount_value, :discount_type, :active)
  end

  def merchant_setup
    @merchant = Merchant.find(params[:merchant_id])
  end
end
