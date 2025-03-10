require "rails_helper"

RSpec.describe Invoice do
  it { should belong_to :merchant }
  it { should belong_to :customer }
  it { should validate_inclusion_of(:status).in_array(%w(shipped packaged returned)) }

  describe 'custom validations' do
    it "should not allow an inactive coupon to be applied" do
      merchant = create(:merchant)
      customer = create(:customer)
      inactive_coupon = create(:coupon, merchant: merchant, active: false)  

      invoice = Invoice.new(customer: customer, merchant: merchant, status: "packaged", coupon: inactive_coupon)

      expect(invoice.valid?).to be false 
      expect(invoice.errors[:coupon_id]).to include("Coupon is not active and cannot be applied")
    end
  end
end