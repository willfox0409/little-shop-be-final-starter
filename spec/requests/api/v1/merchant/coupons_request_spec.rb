require 'rails_helper'

RSpec.describe "Api::V1::Merchants::Coupons", type: :request do
  describe "GET /index" do
    it "should return all of a given merchant's coupons" do
      merchant = create(:merchant)
      create_list(:coupon, 3, merchant: merchant)
      get "/api/v1/merchants/#{merchant.id}/coupons"
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(json[:data]).to be_a Array
      expect(json[:data].count).to eq(3)
      expect(json[:data].first).to include(:id, :type, :attributes)
      expect(json[:data].first[:attributes]).to include(:name, :code, :discount_value, :discount_type, :active)
    end
  end

  describe "GET /show" do
    it "should return a single coupon" do
      merchant = create(:merchant)
      coupon = create(:coupon, merchant: merchant)
      get "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}"
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(json[:data]).to include(:id, :type, :attributes)
      expect(json[:data][:id]).to eq(coupon.id.to_s)
      expect(json[:data][:type]).to eq("coupon")
      expect(json[:data][:attributes]).to include(:name, :code, :discount_value, :discount_type, :active, :usage_count)
      expect(json[:data][:attributes][:name]).to eq(coupon.name)
      expect(json[:data][:attributes][:code]).to eq(coupon.code)
      expect(json[:data][:attributes][:discount_value]).to eq(coupon.discount_value)
      expect(json[:data][:attributes][:discount_type]).to eq(coupon.discount_type)
      expect(json[:data][:attributes][:active]).to eq(coupon.active)
      expect(json[:data][:attributes][:usage_count]).to eq(0) 
    end 
  end

  describe "POST /create" do
    it "should successfully create when validations pass" do
      merchant = create(:merchant)
      coupon_params = {
        coupon: {
          name: "Halloween Special", 
          code: "HALLOWEEN20",
          discount_value: 20,
          discount_type: "percent",
          active: true 
        }
      }

      headers = { "CONTENT_TYPE" => "application/json" }

      post "/api/v1/merchants/#{merchant.id}/coupons", headers: headers, params: JSON.generate(coupon_params)
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:created)
      expect(json[:data]).to include(:id, :type, :attributes)
      expect(json[:data][:type]).to eq("coupon")
      expect(json[:data][:attributes]).to include(:name, :code, :discount_value, :discount_type, :active)
      expect(json[:data][:attributes][:name]).to eq("Halloween Special")
      expect(json[:data][:attributes][:code]).to eq("HALLOWEEN20")
      expect(json[:data][:attributes][:discount_value]).to eq(20)
      expect(json[:data][:attributes][:discount_type]).to eq("percent")
      expect(json[:data][:attributes][:active]).to eq(true)
      expect(json[:data][:attributes][:usage_count]).to eq(0) 
    end
  end

  # describe "Update merchant" do
  #   it "should properly update an existing merchant" do
  #     merchant = create(:merchant)
  #     new_name = "new name"
  #     body = {
  #       name: new_name
  #     }
  #     patch "/api/v1/merchants/#{merchant.id}", params: body, as: :json
  #     json = JSON.parse(response.body, symbolize_names: true)

  #     expect(response).to have_http_status(:ok)
  #     expect(json[:data][:attributes][:name]).to eq(new_name)
  #     expect(Merchant.find(merchant.id).name).to eq(new_name)
  #   end

  #   it "should return 404 when id provided is not valid" do
  #     body = {
  #       name: "new name"
  #     }

  #     patch "/api/v1/merchants/235", params: body, as: :json
  #     json = JSON.parse(response.body, symbolize_names: true)

  #     expect(response).to have_http_status(:not_found)
  #     expect(json[:errors].first).to eq("Couldn't find Merchant with 'id'=235")
  #   end
  # end
end
