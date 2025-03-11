require 'rails_helper'

describe Coupon, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name)}
    it { should validate_presence_of(:code)}
    it { should validate_presence_of(:discount_value)}
    it { should validate_presence_of(:discount_type)}
  end

  describe 'relationships' do
    it { should belong_to :merchant }
    it { should have_many :invoices }
  end

  describe '#increment_usage!' do 
    it 'should increase usage_count by 1' do 
      coupon = create(:coupon, usage_count: 0)

      coupon.increment_usage!
      updated_coupon = Coupon.find(coupon.id) 

      expect(updated_coupon.usage_count).to eq(1) 
    end

    it 'should work even if usage_count is nil' do
      coupon = create(:coupon, usage_count: nil)

      coupon.increment_usage!  
      updated_coupon = Coupon.find(coupon.id)  

      expect(updated_coupon.usage_count).to eq(1)
    end

    describe "default values" do
      it "should default usage_count to zero when created" do
        merchant = create(:merchant)
        new_coupon = create(:coupon, merchant: merchant)
    
        expect(new_coupon.usage_count).to eq(0)
      end
    end
  end

  describe 'custom validations' do
    it "should not allow more than 5 active coupons" do
      merchant = create(:merchant)
      create_list(:coupon, 5, merchant: merchant, active: true)  

      new_coupon = build(:coupon, merchant: merchant, active: true)  

      expect(new_coupon.valid?).to be false  
      expect(new_coupon.errors[:base]).to include("Merchant cannot have more than 5 active coupons")
    end

    it "should not allow duplicate coupon codes at the model level" do
      merchant = create(:merchant)
      create(:coupon, merchant: merchant, code: "UNIQUE50")  
    
      duplicate_coupon = build(:coupon, merchant: merchant, code: "UNIQUE50")
    
      expect(duplicate_coupon.valid?).to be false
      expect(duplicate_coupon.errors[:code]).to include("has already been taken")
    end

    it "should not allow a negative discount value" do
      merchant = create(:merchant)
      invalid_coupon = build(:coupon, merchant: merchant, discount_value: -5)
    
      expect(invalid_coupon.valid?).to be false
      expect(invalid_coupon.errors[:discount_value]).to include("must be greater than 0")
    end
  end

  describe "discount type handling" do
    it "should allow coupons to be either percent-off or dollar-off" do
      merchant = create(:merchant)
  
      dollar_coupon = create(:coupon, merchant: merchant, discount_type: "dollar", discount_value: 10)
      percent_coupon = create(:coupon, merchant: merchant, discount_type: "percent", discount_value: 20)
  
      expect(dollar_coupon.discount_type).to eq("dollar")
      expect(dollar_coupon.discount_value).to eq(10)
  
      expect(percent_coupon.discount_type).to eq("percent")
      expect(percent_coupon.discount_value).to eq(20)
    end
  end

end
