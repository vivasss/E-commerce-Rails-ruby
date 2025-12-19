class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :product_variants, through: :cart_items
  
  validates :session_id, uniqueness: true, allow_nil: true
  
  scope :expired, -> { where("expires_at < ?", Time.current) }
  scope :guest_carts, -> { where(user_id: nil) }
  
  before_create :set_expiration
  
  def subtotal
    cart_items.sum { |item| item.unit_price * item.quantity }
  end
  
  def total_items
    cart_items.sum(:quantity)
  end
  
  def items_count
    cart_items.count
  end
  
  def empty?
    cart_items.empty?
  end
  
  def clear!
    cart_items.destroy_all
  end
  
  def add_item(variant, quantity = 1)
    item = cart_items.find_by(product_variant: variant)
    
    if item
      item.update(quantity: item.quantity + quantity)
    else
      cart_items.create(
        product_variant: variant,
        quantity: quantity,
        unit_price: variant.price
      )
    end
  end
  
  def update_item(variant, quantity)
    item = cart_items.find_by(product_variant: variant)
    return false unless item
    
    if quantity <= 0
      item.destroy
    else
      item.update(quantity: quantity)
    end
  end
  
  def remove_item(variant)
    cart_items.find_by(product_variant: variant)&.destroy
  end
  
  def merge_with(other_cart)
    return if other_cart.nil? || other_cart == self
    
    other_cart.cart_items.each do |item|
      existing = cart_items.find_by(product_variant_id: item.product_variant_id)
      if existing
        existing.update(quantity: existing.quantity + item.quantity)
      else
        item.update(cart_id: id)
      end
    end
    
    other_cart.destroy
  end
  
  def refresh_prices!
    cart_items.each do |item|
      item.update(unit_price: item.product_variant.price)
    end
  end
  
  private
  
  def set_expiration
    self.expires_at ||= 30.days.from_now
  end
end
