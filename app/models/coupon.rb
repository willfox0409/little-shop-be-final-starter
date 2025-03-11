class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  validates :name, presence: true
  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :discount_value, presence: true, numericality: { greater_than: 0 }
  validates :discount_type, presence: true
  validates :usage_count, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  validate :max_active_coupons, on: :create 
  
  attribute :usage_count, :integer, default: 0

  def increment_usage!
    update!(usage_count: (usage_count || 0) + 1)
  end

  def toggle_active!
    if !active? || can_be_deactivated?
      update!(active: !active)
    else
      errors.add(:base, "Cannot deactivate a coupon with pending invoices")
      raise ActiveRecord::RecordInvalid, self
    end
  end

  def self.filter_by_status(status)
    return all unless %w[active inactive].include?(status)  
    where(active: status == "active")  
  end
  
  private
  
  def can_be_deactivated?
    invoices.where(status: "packaged").empty?  
  end

  def max_active_coupons
    return unless merchant 
  
    if active? && merchant.coupons.where(active: true).count >= 5
      errors.add(:base, "Merchant cannot have more than 5 active coupons")
    end
  end
end