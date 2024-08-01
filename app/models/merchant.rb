class Merchant < ApplicationRecord
  validates_presence_of :name
  has_many :items
  has_many :invoices
  # has_many :invoice_items, through: :invoices
  # has_many :customers, through: :invoices
  # has_many :transactions, through: :invoices

  def self.sorted_by_creation
    Merchant.order("created_at DESC")
  end

  def self.filter_by_status(status)
    self.joins(:invoices).where("invoices.status = ?", status).select("distinct merchants.*")
  end

  def item_count
    items.count
  end
end