class Review < ApplicationRecord
  belongs_to :user
  belongs_to :product
  
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :body, length: { maximum: 2000 }, allow_blank: true
  validates :title, length: { maximum: 200 }, allow_blank: true
  validates :user_id, uniqueness: { scope: :product_id, message: "ja avaliou este produto" }
  
  scope :approved, -> { where(approved: true) }
  scope :pending, -> { where(approved: false) }
  scope :verified, -> { where(verified_purchase: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_rating, ->(rating) { where(rating: rating) }
  scope :high_rated, -> { where("rating >= 4") }
  scope :low_rated, -> { where("rating <= 2") }
  
  after_save :update_product_rating
  after_destroy :update_product_rating
  
  def approve!
    update!(approved: true, approved_at: Time.current)
  end
  
  def reject!
    update!(approved: false)
  end
  
  def mark_verified_purchase!
    update!(verified_purchase: true)
  end
  
  def check_verified_purchase
    user.orders
        .joins(:order_items)
        .where(order_items: { product_id: product_id })
        .where(status: [:delivered, :shipped])
        .exists?
  end
  
  private
  
  def update_product_rating
    product.update_rating!
  end
end
