class AddUsageCountToCoupons < ActiveRecord::Migration[7.1]
  def change
    add_column :coupons, :usage_count, :integer
  end
end
