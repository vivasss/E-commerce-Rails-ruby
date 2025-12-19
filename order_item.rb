class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product_variant
  belongs_to :product
  
  validates :product_name, presence: true
  validates :variant_name, presence: true
  validates :sku, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  before_validation :calculate_total
  before_validation :snapshot_product_data, on: :create
  
  delegate :images, to: :product, prefix: true
  
  private
  
  def calculate_total
    self.total_price = unit_price.to_d * quantity.to_i
  end
  
  def snapshot_product_data
    self.product_name ||= product_variant.product.name
    self.variant_name ||= product_variant.name
    self.sku ||= product_variant.sku
    self.unit_price ||= product_variant.price
  end
end
