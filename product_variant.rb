class ProductVariant < ApplicationRecord
  belongs_to :product
  has_many :cart_items, dependent: :destroy
  has_many :order_items, dependent: :restrict_with_error
  
  has_one_attached :image
  
  validates :name, presence: true, length: { maximum: 255 }
  validates :sku, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock_quantity, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :weight, numericality: { greater_than: 0 }, allow_nil: true
  
  scope :active, -> { where(active: true) }
  scope :in_stock, -> { where("stock_quantity > 0") }
  scope :low_stock, ->(threshold = 10) { where("stock_quantity <= ? AND stock_quantity > 0", threshold) }
  scope :out_of_stock, -> { where(stock_quantity: 0) }
  scope :ordered, -> { order(position: :asc) }
  
  def in_stock?
    stock_quantity.positive?
  end
  
  def available_quantity
    stock_quantity
  end
  
  def reserve_stock!(quantity)
    return false if stock_quantity < quantity
    decrement!(:stock_quantity, quantity)
  end
  
  def release_stock!(quantity)
    increment!(:stock_quantity, quantity)
  end
  
  def on_sale?
    compare_at_price.present? && compare_at_price > price
  end
  
  def discount_percentage
    return 0 unless on_sale?
    ((compare_at_price - price) / compare_at_price * 100).round
  end
  
  def options_display
    options = []
    options << "#{option1_name}: #{option1_value}" if option1_name.present?
    options << "#{option2_name}: #{option2_value}" if option2_name.present?
    options << "#{option3_name}: #{option3_value}" if option3_name.present?
    options.join(" / ")
  end
  
  def full_name
    "#{product.name} - #{name}"
  end
end
