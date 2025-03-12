class Api::V1::ItemsController < ApplicationController
  def index
    items = Item.all

    if params[:sorted].present? && params[:sorted] == "price"
      items = Item.sort_by_price
    end

    render json: ItemSerializer.new(items), status: :ok
  end

  def show
    item = Item.find(params[:id])
    render json: ItemSerializer.new(item), status: :ok
  end

  def create
    item = Item.create!(item_params) 
    render json: ItemSerializer.new(item), status: :created
  end

  def update
    item = Item.find(params[:id])
    if !item_params[:merchant_id].nil?
      merchant = Merchant.find(item_params[:merchant_id])
    end
    item.update(item_params)
    item.save

    render json: ItemSerializer.new(item), status: :ok
  end

  def destroy
    item = Item.find(params[:id])
    item.destroy
  end

  private

  def item_params
    params.permit(:name, :description, :unit_price, :merchant_id)
  end
end
