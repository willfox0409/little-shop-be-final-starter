class Item < ApplicationRecord
  validates :name, presence: true
  validates :description, presence: true
  validates :unit_price, presence: true, numericality: true
  belongs_to :merchant
  # has_many :invoice_items
  # has_many :invoices, through: :invoice_items

  def self.find_one_item_by_name(name)
    Item.where("name iLIKE ?", "%#{name}%").order(:name).first
  end

  def self.find_one_item_by_price(min_price: 0, max_price: Float::INFINITY)
    Item.where("unit_price > #{min_price} AND unit_price < #{max_price}")
  end

  def self.search_one_by_name(name)
    search_all_by_name(name).order(:name).first
  end

  def self.search_one_by_max_min(min_price: "0", max_price: Float::MAX)
    search_all_by_max_min(min_price: min_price, max_price: max_price).order(:name).first
  end

  def self.search_all_by_name(name)
    where("lower(name) like ?", "%#{name.downcase}%")
  end

  def self.search_all_by_max_min(min_price:"0", max_price:Float::MAX)
    min_price = '0' unless min_price
    max_price = Float::MAX unless max_price
    return where(unit_price: min_price.to_i..max_price.to_i) if max_price.class == String
    return where(unit_price: min_price.to_i..max_price) if max_price.class != String
  end
end