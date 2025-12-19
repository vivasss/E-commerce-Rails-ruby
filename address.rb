class Address < ApplicationRecord
  belongs_to :user
  
  enum address_type: { shipping: 0, billing: 1 }
  
  validates :name, presence: true, length: { maximum: 100 }
  validates :street, presence: true, length: { maximum: 255 }
  validates :number, presence: true, length: { maximum: 20 }
  validates :neighborhood, presence: true, length: { maximum: 100 }
  validates :city, presence: true, length: { maximum: 100 }
  validates :state, presence: true, length: { maximum: 2 }
  validates :postal_code, presence: true, length: { maximum: 10 }
  validates :country, presence: true, length: { maximum: 2 }
  validates :phone, length: { maximum: 20 }, allow_blank: true
  
  before_save :ensure_single_default
  
  scope :shipping_addresses, -> { where(address_type: :shipping) }
  scope :billing_addresses, -> { where(address_type: :billing) }
  scope :default_first, -> { order(default: :desc) }
  
  def full_address
    parts = [street, number]
    parts << complement if complement.present?
    parts << neighborhood
    parts << "#{city} - #{state}"
    parts << postal_code
    parts.join(", ")
  end
  
  def one_line
    "#{street}, #{number} - #{city}/#{state}"
  end
  
  private
  
  def ensure_single_default
    return unless default?
    user.addresses.where(address_type: address_type, default: true).where.not(id: id).update_all(default: false)
  end
end
