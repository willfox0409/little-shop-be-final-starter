require "rails_helper"

describe "Merchants API", :type => :request do
  describe "Get all merchants" do
    it "should return a properly array of merchants" do
      create_list(:merchant, 5)
      get "/api/v1/merchants"
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(json[:data]).to be_a Array
      expect(json[:data].count).to eq(5)
      expect(json[:data].first).to include(:id, :type, :attributes)
      expect(json[:data].first[:attributes]).to include(:name)
    end

    it "should return a data key even when there are no merchants to return" do
      get "/api/v1/merchants"
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(json).to include(:data)
      expect(json[:data]).to be_empty
    end

    it "should return merchants sorted newest to oldest when sent sort param" do
      middle = Merchant.create!(name: "old merchant")
      first = Merchant.create!(name: "newer merchant")
      last = create(:merchant, created_at: 1.day.ago)

      get "/api/v1/merchants?sorted=age"
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(json[:data][0][:attributes][:name]).to eq(first.name)
      expect(json[:data][1][:attributes][:name]).to eq(middle.name)
      expect(json[:data][2][:attributes][:name]).to eq(last.name)
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
end