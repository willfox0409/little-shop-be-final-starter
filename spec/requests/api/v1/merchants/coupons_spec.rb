require 'rails_helper'

RSpec.describe "Api::V1::Merchants::Coupons", type: :request do
  describe "GET /index" do
    it "should return all of a given merchant's coupons" do
      create_list(:merchant, 5)
      get "/api/v1/merchants"
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(json[:data]).to be_a Array
      expect(json[:data].count).to eq(5)
      expect(json[:data].first).to include(:id, :type, :attributes)
      expect(json[:data].first[:attributes]).to include(:name)
    end
  end

  describe "get a merchant by id" do
    it "should return a single merchant with the correct id" do
      merchant = Merchant.create!(name: "Joe & Sons")
      get "/api/v1/merchants/#{merchant.id}"
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(json[:data]).to include(:id, :type, :attributes)
      expect(json[:data][:id]).to eq(merchant.id.to_s)
      expect(json[:data][:type]).to eq("merchant")
      expect(json[:data][:attributes]).to include(:name)
      expect(json[:data][:attributes][:name]).to eq(merchant.name)
    end

    it "should return 404 and error message when merchant is not found" do
      get "/api/v1/merchants/100"
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:not_found)
      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to be_a Array
      expect(json[:errors].first).to eq("Couldn't find Merchant with 'id'=100")
    end
  end

  describe "create a merchant" do
    it "should successfully create when name is present" do
      name = "Crafty Coders"
      body = {
        name: name
      }

      post "/api/v1/merchants", params: body, as: :json
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:created)
      expect(json[:data][:attributes][:name]).to eq(name)
      expect(json[:data][:type]).to eq("merchant")

      expect(Merchant.last.name).to eq(name)
    end

    it "should display an error message if not all fields are present" do

      post "/api/v1/merchants", params: {}, as: :json
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:errors].first).to eq("Validation failed: Name can't be blank")
    end

    it "should ignore unnecessary fields" do
      body = {
        name: "Crafty Coders",
        address: "test",
        unit_price: 354.35,
        extra_field: "malicious stuff"
      }

      post "/api/v1/merchants", params: body, as: :json
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:created)
      expect(json[:data][:attributes]).to_not include(:extra_field)
      expect(json[:data][:attributes]).to include(:name)
    end
  end

  describe "Update merchant" do
    it "should properly update an existing merchant" do
      merchant = create(:merchant)
      new_name = "new name"
      body = {
        name: new_name
      }
      patch "/api/v1/merchants/#{merchant.id}", params: body, as: :json
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(json[:data][:attributes][:name]).to eq(new_name)
      expect(Merchant.find(merchant.id).name).to eq(new_name)
    end

    it "should return 404 when id provided is not valid" do
      body = {
        name: "new name"
      }

      patch "/api/v1/merchants/235", params: body, as: :json
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:not_found)
      expect(json[:errors].first).to eq("Couldn't find Merchant with 'id'=235")
    end
  end
end
