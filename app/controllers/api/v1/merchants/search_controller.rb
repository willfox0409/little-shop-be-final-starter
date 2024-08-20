class Api::V1::Merchants::SearchController < ApplicationController
  before_action :validate_params
  def index
      render json: MerchantSerializer.new(Merchant.find_all_by_name(params[:name]))
  end

  def show
    found_merchant = Merchant.find_one_merchant_by_name(params[:name])
    if found_merchant.present?
      render json: MerchantSerializer.new(found_merchant)
    else
      render json: { data: {} }
    end
  end

  private

  def validate_params
    render_error if !params[:name].present? || params[:name] == ""
  end
end