require "rails_helper"

RSpec.describe "Merchant invoices endpoints" do
  before :each do
    @merchant2 = Merchant.create!(name: "Merchant")
    @merchant1 = Merchant.create!(name: "Merchant Again")

    @customer1 = Customer.create!(first_name: "Papa", last_name: "Gino")
    @customer2 = Customer.create!(first_name: "Jimmy", last_name: "John")

    @invoice1 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "packaged")
    @invoice2 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "shipped")
    @invoice3 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "shipped")
    @invoice4 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "shipped")
    @invoice5 = Invoice.create!(customer: @customer1, merchant: @merchant2, status: "shipped")

    @coupon = create(:coupon, merchant: @merchant1)
  end

  it "should return all invoices for a given merchant based on status param" do
    get "/api/v1/merchants/#{@merchant1.id}/invoices?status=packaged"

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(json[:data].count).to eq(1)
    expect(json[:data][0][:id]).to eq(@invoice1.id.to_s)
    expect(json[:data][0][:type]).to eq("invoice")
    expect(json[:data][0][:attributes][:customer_id]).to eq(@customer1.id)
    expect(json[:data][0][:attributes][:merchant_id]).to eq(@merchant1.id)
    expect(json[:data][0][:attributes][:status]).to eq("packaged")
  end

  it "should get multiple invoices if they exist for a given merchant and status param" do
    get "/api/v1/merchants/#{@merchant1.id}/invoices?status=shipped"

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(json[:data].count).to eq(3)
  end

  it "should only get invoices for merchant given" do
    get "/api/v1/merchants/#{@merchant2.id}/invoices?status=shipped"

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(json[:data].count).to eq(1)
    expect(json[:data][0][:id]).to eq(@invoice5.id.to_s)
  end

  it "should return 404 and error message when merchant is not found" do
    get "/api/v1/merchants/100000/customers"

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to have_http_status(:not_found)
    expect(json[:message]).to eq("Your query could not be completed")
    expect(json[:errors]).to be_a Array
    expect(json[:errors].first).to eq("Couldn't find Merchant with 'id'=100000")
  end

  it "should return all invoices for a given merchant without status filter" do
    get "/api/v1/merchants/#{@merchant1.id}/invoices"

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(json[:data].count).to eq(4)
    expect(json[:data].map { |invoice| invoice[:id] }).to match_array([@invoice1.id.to_s, @invoice2.id.to_s, @invoice3.id.to_s, @invoice4.id.to_s])
  end

  describe "GET /index (Merchant Invoices with Coupon ID)" do
    before :each do
      @merchant = create(:merchant)
      @customer1 = create(:customer)
      @customer2 = create(:customer)
      @coupon1 = create(:coupon, merchant: @merchant)
      @coupon2 = create(:coupon, merchant: @merchant)
      
      @invoice1 = create(:invoice, merchant: @merchant, customer: @customer1, status: "shipped", coupon: @coupon1)
      @invoice2 = create(:invoice, merchant: @merchant, customer: @customer2, status: "shipped", coupon: @coupon2)
      @invoice3 = create(:invoice, merchant: @merchant, customer: @customer1, status: "shipped", coupon: nil)  # ✅ No coupon used
    end
  
    it "should return all invoices for a merchant, including coupon_id if one was used" do
      get "/api/v1/merchants/#{@merchant.id}/invoices"
  
      json = JSON.parse(response.body, symbolize_names: true)
  
      expect(response).to be_successful
      expect(json[:data].count).to eq(3)
  
      invoice1_data = json[:data][0]  
      invoice2_data = json[:data][1]  
      invoice3_data = json[:data][2]  
  
      expect(invoice1_data[:attributes][:coupon_id]).to eq(@invoice1.coupon_id)
      expect(invoice2_data[:attributes][:coupon_id]).to eq(@invoice2.coupon_id)
      expect(invoice3_data[:attributes][:coupon_id]).to be_nil  
    end
  end

  describe "GET /index (Merchant Invoices with Coupon ID) - Sad Paths" do
    it "should return a 404 error if the merchant does not exist" do
      get "/api/v1/merchants/999999/invoices"  # Invalid Merchant
    
      json = JSON.parse(response.body, symbolize_names: true)
    
      expect(response).to have_http_status(:not_found)
      expect(json[:errors].first).to match(/^Couldn't find Merchant/)
    end

    it "should return an empty array if the merchant has no invoices" do
      merchant = create(:merchant)  #Create a merchant without invoices
    
      get "/api/v1/merchants/#{merchant.id}/invoices"
    
      json = JSON.parse(response.body, symbolize_names: true)
    
      expect(response).to have_http_status(:ok)
      expect(json[:data]).to be_an(Array)
      expect(json[:data]).to be_empty  # Ensures it returns an empty array
    end
  end

  describe "POST /create" do 
    it "should successfully create an invoice for a merchant" do 
      invoice_params = {
        invoice: {
          customer_id: @customer1.id,
          status: "packaged",
          coupon_id: @coupon.id  
        }
      }

      headers = { "CONTENT_TYPE" => "application/json" }

      post "/api/v1/merchants/#{@merchant1.id}/invoices", headers: headers, params: JSON.generate(invoice_params)
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:created)
      expect(json[:data]).to include(:id, :type, :attributes)
      expect(json[:data][:type]).to eq("invoice")
      expect(json[:data][:attributes]).to include(:merchant_id, :customer_id, :status)
      expect(json[:data][:attributes][:merchant_id]).to eq(@merchant1.id)
      expect(json[:data][:attributes][:customer_id]).to eq(@customer1.id)
      expect(json[:data][:attributes][:status]).to eq("packaged")
      expect(json[:data][:attributes][:coupon_id]).to eq(@coupon.id)
    end

    it "should create an invoice without a coupon" do
      invoice_params = {
        invoice: {
          customer_id: @customer1.id,
          status: "shipped"
        }
      }

      headers = { "CONTENT_TYPE" => "application/json" }

      post "/api/v1/merchants/#{@merchant1.id}/invoices", headers: headers, params: JSON.generate(invoice_params)
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:created)
      expect(json[:data][:attributes][:coupon_id]).to be_nil  
    end
  end
end
