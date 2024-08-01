require 'rails_helper'

describe Item, type: :model do
  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :description }
    it { should validate_presence_of :unit_price }
  end

  describe 'relationships' do
    it { should belong_to :merchant }
  end

  describe "class methods" do
    it "should sort items by price, cheapest to most expensive" do
      middle = create(:item, unit_price: 145)
      cheap = create(:item, unit_price: 100)
      expensive = create(:item, unit_price: 1000)

      expect(Item.sort_by_price).to eq([cheap, middle, expensive])
    end
  end

  describe 'search functions' do
    let(:merchant) { create(:merchant) }
    it 'should return the first item by name' do
      item1 = create(:item, name: 'Apple of my eye', merchant: merchant)
      create(:item, name: 'pineapple', merchant: merchant)
      create(:item, name: 'Golden delicious apple', merchant: merchant)

      item_found = Item.find_one_item_by_name('APPLE')
      expect(item_found.id).to eq(item1.id)
    end

    it 'should return the item that satisfies the price query' do
      item1 = create(:item, name: 'grapes', unit_price: 4.99, merchant: merchant)
      item2 = create(:item, name: 'oreos', unit_price: 1.05, merchant: merchant)
      item3 = create(:item, name: 'bananas', unit_price: 15.50, merchant: merchant)

      item_found = Item.find_one_item_by_price(max_price: 5)
    end
  end
end