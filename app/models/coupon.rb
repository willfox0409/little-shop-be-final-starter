class Coupon < ApplicationRecord
    belongs_to :merchant
    has_many :invoices

    validates :name, presence: true
    validates :code, presence: true
    validates :discount_value, presence: true, numericality: { greater_than: 0 }
    validates :discount_type, presence: true
    validates :usage_count, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

    attribute :usage_count, :integer, default: 0

    def increment_usage!
        update!(usage_count: (usage_count || 0) + 1)
    end
end