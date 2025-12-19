class CouponUsage < ApplicationRecord
  belongs_to :coupon
  belongs_to :user
  belongs_to :order
  
  validates :coupon_id, uniqueness: { scope: :order_id }
end
