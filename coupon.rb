class Coupon < ApplicationRecord
  enum discount_type: { percentage: 0, fixed_amount: 1, free_shipping: 2 }
  
  has_many :orders
  has_many :coupon_usages, dependent: :destroy
  
  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :discount_type, presence: true
  validates :discount_value, presence: true, numericality: { greater_than: 0 }
  validates :minimum_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :maximum_discount, numericality: { greater_than: 0 }, allow_nil: true
  validates :usage_limit, numericality: { greater_than: 0, only_integer: true }, allow_nil: true
  validates :per_user_limit, numericality: { greater_than: 0, only_integer: true }, allow_nil: true
  
  validate :percentage_max_100
  
  before_save :upcase_code
  
  scope :active, -> { where(active: true) }
  scope :valid_now, -> {
    where("(starts_at IS NULL OR starts_at <= ?) AND (expires_at IS NULL OR expires_at >= ?)", 
          Time.current, Time.current)
  }
  scope :available, -> { active.valid_now.where("usage_limit IS NULL OR usage_count < usage_limit") }
  
  def valid_for_amount?(amount)
    return true if minimum_amount.nil?
    amount >= minimum_amount
  end
  
  def valid_for_user?(user)
    return true if per_user_limit.nil?
    coupon_usages.where(user: user).count < per_user_limit
  end
  
  def available?
    return false unless active?
    return false if expired?
    return false if usage_limit.present? && usage_count >= usage_limit
    true
  end
  
  def expired?
    expires_at.present? && expires_at < Time.current
  end
  
  def started?
    starts_at.nil? || starts_at <= Time.current
  end
  
  def calculate_discount(subtotal)
    return 0 unless available? && started?
    return 0 unless valid_for_amount?(subtotal)
    
    discount = case discount_type
    when "percentage"
      subtotal * (discount_value / 100)
    when "fixed_amount"
      discount_value
    when "free_shipping"
      0
    end
    
    if maximum_discount.present?
      [discount, maximum_discount].min
    else
      discount
    end
  end
  
  def increment_usage!
    increment!(:usage_count)
  end
  
  private
  
  def upcase_code
    self.code = code.upcase.strip
  end
  
  def percentage_max_100
    return unless percentage? && discount_value.present? && discount_value > 100
    errors.add(:discount_value, "nao pode ser maior que 100%")
  end
end
