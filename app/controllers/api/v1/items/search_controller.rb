class Api::V1::Items::SearchController < ApplicationController
  before_action :validate_params

  def show
    if params[:name].present?
      item = Item.find_one_item_by_name(params[:name])
      render json: ItemSerializer.new(item), status: :ok
    else
      min = params[:min_price] if params[:min_price]
      max = params[:max_price] if params[:max_price]
      item = Item.find_one_item_by_price(min_price: min, max_price: max)
      render json: ItemSerializer.new(item)
    end
  end

  def index
    if params[:name].present?
      item = Item.find_all_by_name(params[:name])
      render json: ItemSerializer.new(item), status: :ok
    else
      min = params[:min_price] if params[:min_price]
      max = params[:max_price] if params[:max_price]
      items = Item.find_items_by_price(min_price: min, max_price: max)
      render json: ItemSerializer.new(items)
    end
  end

  private

  def validate_params
    render_error if price_params_negative?(params)
    render_error if no_search_params?(params)
    render_error if name_and_price_params_included?(params)
  end

  def name_and_price_params_included?(params)
    params.include?(:name) && (params.include?(:min_price) || params.include?(:max_price))
  end

  def price_params_negative?(params)
    return true if params[:min_price].present? && params[:min_price].to_f < 0

    params[:max_price].present? && params[:max_price].to_f < 0
  end

  def no_search_params?(params)
    !params[:min_price].present? && !params[:max_price].present? && !params[:name].present?
  end

  def render_error
    render json: { 
      message: "your query could not be completed", 
      error: ["invalid search params"] },
        status: :bad_request
  end
end