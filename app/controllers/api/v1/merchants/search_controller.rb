class Api::V1::Merchants::SearchController < ApplicationController
  before_action :validate_params
  def index
    render json: MerchantSerializer.new(Merchant.find_all_by_name(params[:name]))
  end

  def show
    render json: MerchantSerializer.new(Merchant.find_one_merchant_by_name(params[:name]))
  end

  private

  def validate_params
    render_error if !params[:name].present? || params[:name] == ""
  end

  def render_error
    render json: { 
      message: "your query could not be completed", 
      error: ["invalid search params"] },
        status: :bad_request
  end
end