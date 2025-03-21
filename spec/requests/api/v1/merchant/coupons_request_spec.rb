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

  describe "GET /index (Filtered by Coupon Status)" do
    before :each do
      @merchant = create(:merchant)
      @active_coupon = create(:coupon, merchant: @merchant, active: true)
      @inactive_coupon = create(:coupon, merchant: @merchant, active: false)
    end
  
    it "should return only active coupons when status=active" do
      get "/api/v1/merchants/#{@merchant.id}/coupons?status=active"
  
      json = JSON.parse(response.body, symbolize_names: true)
  
      expect(response).to be_successful
      expect(json[:data].count).to eq(1)
      expect(json[:data].first[:attributes][:active]).to be true
    end
  
    it "should return only inactive coupons when status=inactive" do
      get "/api/v1/merchants/#{@merchant.id}/coupons?status=inactive"
  
      json = JSON.parse(response.body, symbolize_names: true)
  
      expect(response).to be_successful
      expect(json[:data].count).to eq(1)
      expect(json[:data].first[:attributes][:active]).to be false
    end
  
    it "should return all coupons if no status param is given" do
      get "/api/v1/merchants/#{@merchant.id}/coupons"
  
      json = JSON.parse(response.body, symbolize_names: true)
  
      expect(response).to be_successful
      expect(json[:data].count).to eq(2)  
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

  describe "GET /show (Sad Path)" do
    it "should return a 404 error if the coupon does not exist" do
      merchant = create(:merchant)
  
      get "/api/v1/merchants/#{merchant.id}/coupons/999999"  # Invalid Coupon ID
  
      json = JSON.parse(response.body, symbolize_names: true)
  
      expect(response).to have_http_status(:not_found)
      expect(json[:errors].first).to match(/^Couldn't find Coupon/) # Use Regex to match the beginning of string
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

  describe "POST /create (Sad Paths)" do
    it "should not allow a merchant to have more than 5 active coupons" do
      merchant = create(:merchant)
      create_list(:coupon, 5, merchant: merchant, active: true)  
  
      new_coupon_params = {
        coupon: {
          name: "Extra Discount",
          code: "EXTRA10",
          discount_value: 10,
          discount_type: "percent",
          active: true  # should fail because this makes 6 active!
        }
      }
  
      headers = { "CONTENT_TYPE" => "application/json" }
  
      post "/api/v1/merchants/#{merchant.id}/coupons", headers: headers, params: JSON.generate(new_coupon_params)
      json = JSON.parse(response.body, symbolize_names: true)
  
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:errors]).to include("Validation failed: Merchant cannot have more than 5 active coupons")
    end
  
    it "should not allow duplicate coupon codes" do
      merchant = create(:merchant)
      create(:coupon, merchant: merchant, code: "UNIQUE50")  
  
      duplicate_coupon_params = {
        coupon: {
          name: "Duplicate Discount",
          code: "UNIQUE50",  # code is already in use
          discount_value: 50,
          discount_type: "dollar",
          active: true
        }
      }
  
      headers = { "CONTENT_TYPE" => "application/json" }
  
      post "/api/v1/merchants/#{merchant.id}/coupons", headers: headers, params: JSON.generate(duplicate_coupon_params)
      json = JSON.parse(response.body, symbolize_names: true)
  
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:errors]).to include("Validation failed: Code has already been taken")
    end

    it "should return 422 if required attributes are missing" do
      merchant = create(:merchant)
  
      invalid_coupon_params = {
        coupon: {
          name: "",  # Name is missing
          code: "",  # Code is missing
          discount_value: nil,  # Discount value is missing
          discount_type: "percent"
        }
      }
  
      headers = { "CONTENT_TYPE" => "application/json" }
  
      post "/api/v1/merchants/#{merchant.id}/coupons", headers: headers, params: JSON.generate(invalid_coupon_params)
      json = JSON.parse(response.body, symbolize_names: true)
  
      expect(response).to have_http_status(:unprocessable_entity)
      error_messages = json[:errors].first.split(", ")
      expect(error_messages).to include(
        "Validation failed: Name can't be blank", 
        "Code can't be blank", 
        "Discount value can't be blank",
        "Discount value is not a number"
        )
    end
  end

  describe "PATCH /update" do
    it "should properly update an existing coupon" do
      merchant = create(:merchant)
      coupon = create(:coupon, merchant: merchant, name: "Halloween Special")
        
      new_name = "Spooky Savings"
      body = {
        coupon: {
        name: new_name
      }
      }
      patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}", params: JSON.generate(body), headers: { "CONTENT_TYPE" => "application/json" }
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(json[:data][:attributes][:name]).to eq(new_name)
      expect(coupon.reload.name).to eq(new_name)
    end
  end

  describe "PATCH /update (Coupon Activation/Deactivation)" do
    it "should deactivate an active coupon" do
      merchant = create(:merchant)
      coupon = create(:coupon, merchant: merchant, active: true)  # Starts as active
  
      patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}", 
            headers: { "CONTENT_TYPE" => "application/json" }, 
            params: JSON.generate(coupon: { active: false })  # Deactivate it
  
      json = JSON.parse(response.body, symbolize_names: true)
  
      expect(response).to have_http_status(:ok)
      expect(json[:data][:attributes][:active]).to be false
    end
  
    it "should activate a deactivated coupon" do
      merchant = create(:merchant)
      coupon = create(:coupon, merchant: merchant, active: false)  # Start as inactive
  
      patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}", 
            headers: { "CONTENT_TYPE" => "application/json" }, 
            params: JSON.generate(coupon: { active: true })  # Activate it
  
      json = JSON.parse(response.body, symbolize_names: true)
  
      expect(response).to have_http_status(:ok)
      expect(json[:data][:attributes][:active]).to be true
    end
  end

  describe "PATCH /update (Coupon Activation/Deactivation) - Sad Paths" do
    it "should not allow a coupon to be deactivated if there are pending invoices" do
      merchant = create(:merchant)
      coupon = create(:coupon, merchant: merchant, active: true) # Active Coupon
  
      customer = create(:customer)
      invoice = create(:invoice, merchant: merchant, customer: customer, status: "packaged", coupon: coupon) # Pending invoice
  
      patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}", 
            headers: { "CONTENT_TYPE" => "application/json" }, 
            params: JSON.generate(coupon: { active: false })  # attempt to deactivate
  
      json = JSON.parse(response.body, symbolize_names: true)
  
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:errors]).to include("Validation failed: Cannot deactivate a coupon with pending invoices")
      expect(coupon.reload.active).to be true  
    end
  end
end