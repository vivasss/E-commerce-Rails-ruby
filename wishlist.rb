class Wishlist < ApplicationRecord
  belongs_to :user
  has_many :wishlist_items, dependent: :destroy
  has_many :products, through: :wishlist_items
  
  validates :name, presence: true, length: { maximum: 100 }
  validates :name, uniqueness: { scope: :user_id }
  
  def add_product(product)
    return false if products.include?(product)
    wishlist_items.create(product: product)
  end
  
  def remove_product(product)
    wishlist_items.find_by(product: product)&.destroy
  end
  
  def includes_product?(product)
    products.include?(product)
  end
  
  def items_count
    wishlist_items.count
  end
end
