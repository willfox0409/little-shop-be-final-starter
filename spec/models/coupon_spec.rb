require 'rails_helper'

describe Coupon, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name)}
    it { should validate_presence_of(:code)}
    it { should validate_presence_of(:discount_value)}
    it { should validate_presence_of(:discount_type)}
  end

  describe 'relationships' do
    it { should belong_to :merchants }
    it { should have_many :invoices }
  end
