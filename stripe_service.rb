module Payments
  class StripeService < PaymentGateway
    def create_payment(amount, payment_method_id = nil)
      create_payment_record(:stripe, amount)
      
      intent = Stripe::PaymentIntent.create({
        amount: (amount * 100).to_i,
        currency: "brl",
        payment_method: payment_method_id,
        confirmation_method: "manual",
        confirm: payment_method_id.present?,
        metadata: {
          order_id: order.id,
          order_number: order.number,
          payment_id: @payment.id
        }
      })
      
      @payment.update!(
        gateway_payment_id: intent.id,
        metadata: { client_secret: intent.client_secret }
      )
      
      if intent.status == "succeeded"
        @payment.mark_as_paid!(intent.id)
      end
      
      { payment: @payment, intent: intent }
    rescue Stripe::StripeError => e
      @payment&.mark_as_failed!(e.message)
      { error: e.message, payment: @payment }
    end
    
    def confirm_payment(payment_intent_id)
      intent = Stripe::PaymentIntent.confirm(payment_intent_id)
      
      payment = order.payments.find_by(gateway_payment_id: payment_intent_id)
      
      if intent.status == "succeeded"
        payment.mark_as_paid!(intent.id)
        { success: true, payment: payment }
      else
        { success: false, status: intent.status }
      end
    rescue Stripe::StripeError => e
      { error: e.message }
    end
    
    def process_webhook(payload, signature)
      event = Stripe::Webhook.construct_event(
        payload,
        signature,
        Rails.configuration.stripe[:webhook_secret]
      )
      
      case event.type
      when "payment_intent.succeeded"
        handle_payment_succeeded(event.data.object)
      when "payment_intent.payment_failed"
        handle_payment_failed(event.data.object)
      end
      
      { received: true }
    rescue Stripe::SignatureVerificationError => e
      { error: "Invalid signature" }
    end
    
    def refund(payment, amount = nil)
      refund_amount = amount || payment.amount
      
      refund = Stripe::Refund.create({
        payment_intent: payment.gateway_payment_id,
        amount: (refund_amount * 100).to_i
      })
      
      if refund.status == "succeeded"
        payment.process_refund!(refund_amount)
        { success: true, refund: refund }
      else
        { success: false, status: refund.status }
      end
    rescue Stripe::StripeError => e
      { error: e.message }
    end
    
    private
    
    def handle_payment_succeeded(intent)
      payment = Payment.find_by(gateway_payment_id: intent.id)
      payment&.mark_as_paid!(intent.id)
    end
    
    def handle_payment_failed(intent)
      payment = Payment.find_by(gateway_payment_id: intent.id)
      error = intent.last_payment_error&.message || "Payment failed"
      payment&.mark_as_failed!(error)
    end
  end
end
