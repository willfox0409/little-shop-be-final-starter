class Api::V1::Merchant::CustomersController < ApplicationController
  def index
    merchant = Merchant.find(params[:merchant_id])
    render json: CustomerSerializer.new(merchant.distinct_customers)
  end
end