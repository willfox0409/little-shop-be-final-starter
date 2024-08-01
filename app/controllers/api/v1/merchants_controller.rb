class Api::V1::MerchantsController < ApplicationController

  def index
    if params[:sorted].present? && params[:sorted] == "age"
      merchants = Merchant.order("created_at DESC")
    else
      merchants = Merchant.all
    end

    render json: MerchantSerializer.new(merchants), status: :ok
  end

  def show
    merchant = Merchant.find(params[:id])
    render json: MerchantSerializer.new(merchant), status: :ok
  end
end
