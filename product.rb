class Product < ApplicationRecord
  include PgSearch::Model
  extend FriendlyId
  
  friendly_id :name, use: :slugged
  
  belongs_to :category
  has_many :variants, class_name: "ProductVariant", dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :order_items, dependent: :restrict_with_error
  has_many :wishlist_items, dependent: :destroy
  
  has_many_attached :images
  
  validates :name, presence: true, length: { maximum: 255 }
  validates :slug, presence: true, uniqueness: true
  validates :base_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :compare_at_price, numericality: { greater_than: 0 }, allow_nil: true
  
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :featured, -> { where(featured: true) }
  scope :in_stock, -> { joins(:variants).where("product_variants.stock_quantity > 0").distinct }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :price_range, ->(min, max) { where(base_price: min..max) }
  scope :recent, -> { order(created_at: :desc) }
  scope :popular, -> { order(total_sold: :desc) }
  scope :top_rated, -> { order(average_rating: :desc) }
  
  pg_search_scope :search_by_term,
    against: [:name, :description, :short_description, :sku],
    using: {
      tsearch: { prefix: true, dictionary: "portuguese" },
      trigram: { threshold: 0.3 }
    },
    ignoring: :accents
  
  def price_range
    prices = variants.active.pluck(:price)
    return { min: base_price, max: base_price } if prices.empty?
    { min: prices.min, max: prices.max }
  end
  
  def in_stock?
    variants.active.where("stock_quantity > 0").exists?
  end
  
  def total_stock
    variants.active.sum(:stock_quantity)
  end
  
  def default_variant
    variants.active.order(:position).first
  end
  
  def on_sale?
    compare_at_price.present? && compare_at_price > base_price
  end
  
  def discount_percentage
    return 0 unless on_sale?
    ((compare_at_price - base_price) / compare_at_price * 100).round
  end
  
  def update_rating!
    approved_reviews = reviews.where(approved: true)
    self.reviews_count = approved_reviews.count
    self.average_rating = approved_reviews.average(:rating) || 0
    save!
  end
  
  def related_products(limit = 4)
    Product.active
           .where(category_id: category_id)
           .where.not(id: id)
           .limit(limit)
  end
end
