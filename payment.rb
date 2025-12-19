class Payment < ApplicationRecord
  belongs_to :order
  
  enum gateway: { stripe: 0, pagseguro: 1, mercadopago: 2 }
  enum status: { pending: 0, processing: 1, paid: 2, failed: 3, refunded: 4, cancelled: 5 }
  
  validates :gateway, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true
  
  scope :successful, -> { where(status: :paid) }
  scope :failed, -> { where(status: :failed) }
  scope :recent, -> { order(created_at: :desc) }
  
  def mark_as_paid!(gateway_payment_id = nil)
    update!(
      status: :paid,
      paid_at: Time.current,
      gateway_payment_id: gateway_payment_id
    )
    order.confirm! if order.pending?
  end
  
  def mark_as_failed!(error_message = nil)
    update!(
      status: :failed,
      error_message: error_message
    )
  end
  
  def process_refund!(amount = nil, reason = nil)
    refund_amt = amount || self.amount
    update!(
      status: :refunded,
      refunded_at: Time.current,
      refund_amount: refund_amt,
      refund_reason: reason
    )
    order.refund! if order.delivered? || order.shipped?
  end
  
  def can_refund?
    paid? && refunded_at.nil?
  end
  
  def gateway_reference
    gateway_payment_id || id
  end
end
