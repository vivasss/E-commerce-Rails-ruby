class PaymentStatusJob < ApplicationJob
  queue_as :payments
  
  def perform(payment_id)
    payment = Payment.find_by(id: payment_id)
    return unless payment
    
    case payment.gateway
    when "stripe"
      check_stripe_payment(payment)
    when "mercadopago"
      check_mercadopago_payment(payment)
    end
  end
  
  private
  
  def check_stripe_payment(payment)
    return unless payment.gateway_payment_id.present?
    
    intent = Stripe::PaymentIntent.retrieve(payment.gateway_payment_id)
    
    case intent.status
    when "succeeded"
      payment.mark_as_paid!(intent.id) unless payment.paid?
    when "canceled"
      payment.mark_as_failed!("Payment cancelled")
    end
  end
  
  def check_mercadopago_payment(payment)
    return unless payment.gateway_payment_id.present?
    
    sdk = Mercadopago::SDK.new(ENV["MERCADOPAGO_ACCESS_TOKEN"])
    result = sdk.payment.search({ external_reference: payment.id })
    
    return unless result[:status] == 200
    
    mp_payments = result[:response]["results"]
    return if mp_payments.empty?
    
    mp_payment = mp_payments.first
    
    case mp_payment["status"]
    when "approved"
      payment.mark_as_paid!(mp_payment["id"].to_s) unless payment.paid?
    when "rejected", "cancelled"
      payment.mark_as_failed!(mp_payment["status_detail"])
    end
  end
end
