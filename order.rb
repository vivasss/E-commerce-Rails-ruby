class Order < ApplicationRecord
  include AASM
  
  belongs_to :user
  belongs_to :coupon, optional: true
  has_many :order_items, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_one :shipment, dependent: :destroy
  has_many :coupon_usages
  
  enum status: {
    pending: 0,
    confirmed: 1,
    processing: 2,
    shipped: 3,
    delivered: 4,
    cancelled: 5,
    refunded: 6
  }
  
  validates :number, presence: true, uniqueness: true
  validates :subtotal, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :shipping_name, presence: true
  validates :shipping_street, presence: true
  validates :shipping_city, presence: true
  validates :shipping_state, presence: true
  validates :shipping_postal_code, presence: true
  
  before_validation :generate_number, on: :create
  
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  scope :created_between, ->(start_date, end_date) { where(created_at: start_date..end_date) }
  
  aasm column: :status, enum: true do
    state :pending, initial: true
    state :confirmed
    state :processing
    state :shipped
    state :delivered
    state :cancelled
    state :refunded
    
    event :confirm do
      transitions from: :pending, to: :confirmed
      after do
        update(confirmed_at: Time.current)
        OrderConfirmationJob.perform_later(id)
      end
    end
    
    event :process_order do
      transitions from: :confirmed, to: :processing
    end
    
    event :ship do
      transitions from: :processing, to: :shipped
      after do
        update(shipped_at: Time.current)
      end
    end
    
    event :deliver do
      transitions from: :shipped, to: :delivered
      after do
        update(delivered_at: Time.current)
      end
    end
    
    event :cancel do
      transitions from: [:pending, :confirmed, :processing], to: :cancelled
      after do
        update(cancelled_at: Time.current)
        restore_stock!
      end
    end
    
    event :refund do
      transitions from: [:delivered, :shipped], to: :refunded
    end
  end
  
  def paid?
    payments.where(status: :paid).exists?
  end
  
  def payment
    payments.order(created_at: :desc).first
  end
  
  def items_total
    order_items.sum(:total_price)
  end
  
  def recalculate_totals!
    self.subtotal = items_total
    self.discount_amount = coupon&.calculate_discount(subtotal) || 0
    self.total = subtotal - discount_amount + shipping_amount + tax_amount
    save!
  end
  
  def shipping_address_full
    [
      shipping_street,
      shipping_number,
      shipping_complement,
      shipping_neighborhood,
      "#{shipping_city} - #{shipping_state}",
      shipping_postal_code
    ].compact.join(", ")
  end
  
  private
  
  def generate_number
    loop do
      self.number = "ORD-#{Time.current.year}-#{SecureRandom.alphanumeric(8).upcase}"
      break unless Order.exists?(number: number)
    end
  end
  
  def restore_stock!
    order_items.each do |item|
      item.product_variant.release_stock!(item.quantity)
    end
  end
end
