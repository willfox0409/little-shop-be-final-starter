class Coupon < ApplicationRecord
    belongs_to :merchant
    has_many :invoices

    validates :name, presence: true
    validates :code, presence: true, uniqueness: { case_sensitive: false }
    validates :discount_value, presence: true, numericality: { greater_than: 0 }
    validates :discount_type, presence: true
    validates :usage_count, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

    validate :max_active_coupons, on: :create 
    validate :coupon_must_be_active, if: -> { coupon_id.present? }

    attribute :usage_count, :integer, default: 0

    def increment_usage!
        update!(usage_count: (usage_count || 0) + 1)
    end

    private

    def max_active_coupons
      if merchant.coupons.where(active: true).count >= 5
        errors.add(:base, "Merchant cannot have more than 5 active coupons")
      end
    end

    def toggle_active!
      update!(active: !active)  
    end

    def coupon_must_be_active
      if coupon && !coupon.active?
        errors.add(:coupon_id, "Coupon is not active and cannot be applied")
      end
    end
end