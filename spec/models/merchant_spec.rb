require 'rails_helper'

describe Merchant, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name)}
  end

  describe 'relationships' do
    it { should have_many :items }
    it { should have_many :invoices }
    it { should have_many(:customers).through(:invoices) }
  end

  describe "class methods" do
    it "should sort merchants by created_at" do
      merchant1 = create(:merchant, created_at: 1.day.ago)
      merchant2 = create(:merchant, created_at: 4.days.ago)
      merchant3 = create(:merchant, created_at: 2.days.ago)

      expect(Merchant.sorted_by_creation).to eq([merchant1, merchant3, merchant2])
    end

    it "should filter merchants by status of invoices" do
      merchant1 = create(:merchant)
      merchant2 = create(:merchant)
      customer = create(:customer)
      create(:invoice, status: "returned", merchant_id: merchant1.id, customer_id: customer.id)
      create_list(:invoice, 5, merchant_id: merchant1.id, customer_id: customer.id)
      create_list(:invoice, 5, merchant_id: merchant2.id, customer_id: customer.id)
      create(:invoice, status: "packaged", merchant_id: merchant2.id, customer_id: customer.id)

      expect(Merchant.filter_by_status("returned")).to eq([merchant1])
      expect(Merchant.filter_by_status("packaged")).to eq([merchant2])
      expect(Merchant.filter_by_status("shipped")).to match_array([merchant1, merchant2])
    end
  end

  describe "instance methods" do
    it "#item_count should return the count of items for a merchant" do
      merchant = create(:merchant)
      merchant2 = create(:merchant)
      create_list(:item, 8, merchant_id: merchant.id)
      create_list(:item, 4, merchant_id: merchant2.id)

      expect(merchant.item_count).to eq(8)
      expect(merchant2.item_count).to eq(4)
    end

    it "#distinct_customers should return all customers for a merchant" do
      merchant1 = create(:merchant)
      customer1 = create(:customer)
      customer2 = create(:customer)
      customer3 = create(:customer)

      merchant2 = create(:merchant)

      create_list(:invoice, 3, merchant_id: merchant1.id, customer_id: customer1.id)
      create_list(:invoice, 2, merchant_id: merchant1.id, customer_id: customer2.id)

      create_list(:invoice, 2, merchant_id: merchant2.id, customer_id: customer3.id)

      expect(merchant1.distinct_customers).to match_array([customer1, customer2])
      expect(merchant2.distinct_customers).to eq([customer3])
    end
  end
end
