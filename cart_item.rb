class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product_variant
  
  has_one :product, through: :product_variant
  
  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :product_variant_id, uniqueness: { scope: :cart_id }
  
  validate :stock_available, on: :update
  
  def total_price
    unit_price * quantity
  end
  
  def product_name
    product_variant.product.name
  end
  
  def variant_name
    product_variant.name
  end
  
  def in_stock?
    product_variant.stock_quantity >= quantity
  end
  
  def available_stock
    product_variant.stock_quantity
  end
  
  private
  
  def stock_available
    return if product_variant.stock_quantity >= quantity
    errors.add(:quantity, "excede o estoque disponivel (#{product_variant.stock_quantity})")
  end
end
