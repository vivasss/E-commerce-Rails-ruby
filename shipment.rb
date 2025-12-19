class Shipment < ApplicationRecord
  belongs_to :order
  
  enum status: { pending: 0, processing: 1, shipped: 2, in_transit: 3, delivered: 4, returned: 5 }
  
  validates :status, presence: true
  
  scope :recent, -> { order(created_at: :desc) }
  scope :pending_shipment, -> { where(status: [:pending, :processing]) }
  
  def mark_as_shipped!(tracking_number, carrier = nil)
    update!(
      status: :shipped,
      shipped_at: Time.current,
      tracking_number: tracking_number,
      carrier: carrier
    )
    order.ship! if order.processing?
  end
  
  def mark_as_delivered!
    update!(
      status: :delivered,
      delivered_at: Time.current
    )
    order.deliver! if order.shipped?
  end
  
  def tracking_available?
    tracking_number.present?
  end
  
  def estimated_delivery
    return nil unless shipped_at
    shipped_at + 7.business_days
  end
end
