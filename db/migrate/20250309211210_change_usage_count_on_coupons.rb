class ChangeUsageCountOnCoupons < ActiveRecord::Migration[7.1]
  def change
      Coupon.where(usage_count: nil).update_all(usage_count: 0)
      change_column_default :coupons, :usage_count, 0
      change_column_null :coupons, :usage_count, false
  end
end
