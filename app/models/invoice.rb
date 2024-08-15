class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant

  validates :status, inclusion: { in: ["shipped", "packaged", "returned"] }
end