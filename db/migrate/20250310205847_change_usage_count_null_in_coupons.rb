class ChangeUsageCountNullInCoupons < ActiveRecord::Migration[7.1]
  def change
    change_column_null :coupons, :usage_count, true
  end
end
