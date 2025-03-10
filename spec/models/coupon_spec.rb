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
      coupon  create(:coupon, usage_count: 0)

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
  end
end
