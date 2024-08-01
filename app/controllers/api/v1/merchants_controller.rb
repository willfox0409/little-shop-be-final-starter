class Api::V1::MerchantsController < ApplicationController

  def index
    merchants = Merchant.all

    if params[:sorted].present? && params[:sorted] == "age"
      merchants = merchants.sorted_by_creation
    elsif params[:status].present?
      merchants = Merchant.filter_by_status(params[:status])
    end

    include_count = params[:count].present? && params[:count] == "true"
    render json: MerchantSerializer.new(merchants, { params: { count: include_count }}), status: :ok
  end

  def show
    merchant = Merchant.find(params[:id])
    render json: MerchantSerializer.new(merchant), status: :ok
  end
end
