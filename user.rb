class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable, :confirmable, :trackable,
         :omniauthable, omniauth_providers: [:google_oauth2, :facebook]
  
  enum role: { customer: 0, admin: 1 }
  
  has_many :addresses, dependent: :destroy
  has_many :orders, dependent: :nullify
  has_many :reviews, dependent: :destroy
  has_many :wishlists, dependent: :destroy
  has_one :cart, dependent: :destroy
  has_many :coupon_usages, dependent: :destroy
  
  validates :name, presence: true, length: { maximum: 100 }
  validates :phone, length: { maximum: 20 }, allow_blank: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :admins, -> { where(role: :admin) }
  scope :customers, -> { where(role: :customer) }
  
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
      user.avatar_url = auth.info.image
      user.skip_confirmation!
    end
  end
  
  def full_address
    addresses.find_by(default: true) || addresses.first
  end
  
  def default_shipping_address
    addresses.where(address_type: :shipping, default: true).first ||
      addresses.where(address_type: :shipping).first
  end
  
  def default_billing_address
    addresses.where(address_type: :billing, default: true).first ||
      addresses.where(address_type: :billing).first
  end
  
  def total_spent
    orders.where(status: [:delivered, :shipped]).sum(:total)
  end
  
  def orders_count
    orders.count
  end
end
