class Coupon < ApplicationRecord
    belongs_to :merchant
    has_many :invoices

    validates :name, presence :true
    validates :code, presence :true
    validates :discount_value, presence :true, numericality: { greater_than: 0 }
    validates :discount_type, presence :true
end