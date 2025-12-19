class WishlistItem < ApplicationRecord
  belongs_to :wishlist
  belongs_to :product
  
  validates :product_id, uniqueness: { scope: :wishlist_id }
  
  delegate :name, :base_price, :images, :in_stock?, to: :product, prefix: true
end
