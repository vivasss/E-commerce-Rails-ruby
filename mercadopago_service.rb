module Payments
  class MercadopagoService < PaymentGateway
    def initialize(order)
      super
      @sdk = Mercadopago::SDK.new(ENV["MERCADOPAGO_ACCESS_TOKEN"])
    end
    
    def create_payment(amount, payment_data = {})
      create_payment_record(:mercadopago, amount)
      
      preference_data = build_preference(amount, payment_data)
      result = @sdk.preference.create(preference_data)
      
      if result[:status] == 201
        preference = result[:response]
        @payment.update!(
          gateway_payment_id: preference["id"],
          metadata: {
            init_point: preference["init_point"],
            sandbox_init_point: preference["sandbox_init_point"]
          }
        )
        
        { payment: @payment, preference: preference }
      else
        @payment.mark_as_failed!(result[:response].to_s)
        { error: result[:response], payment: @payment }
      end
    end
    
    def process_webhook(payload, _signature = nil)
      return { error: "Invalid payload" } unless payload["type"] == "payment"
      
      payment_id = payload.dig("data", "id")
      return { error: "Missing payment ID" } unless payment_id
      
      result = @sdk.payment.get(payment_id)
      return { error: "Payment not found" } unless result[:status] == 200
      
      mp_payment = result[:response]
      external_reference = mp_payment["external_reference"]
      
      payment = Payment.find_by(id: external_reference)
      return { error: "Local payment not found" } unless payment
      
      case mp_payment["status"]
      when "approved"
        payment.mark_as_paid!(mp_payment["id"].to_s)
      when "rejected", "cancelled"
        payment.mark_as_failed!(mp_payment["status_detail"])
      end
      
      { received: true, status: mp_payment["status"] }
    end
    
    def refund(payment, amount = nil)
      refund_amount = amount || payment.amount
      
      result = @sdk.refund.create(payment.gateway_payment_id, { amount: refund_amount })
      
      if result[:status] == 201
        payment.process_refund!(refund_amount)
        { success: true, refund: result[:response] }
      else
        { error: result[:response] }
      end
    end
    
    private
    
    def build_preference(amount, payment_data)
      {
        items: order_items_for_preference,
        payer: payer_data,
        external_reference: @payment.id,
        notification_url: notification_url,
        back_urls: {
          success: success_url,
          failure: failure_url,
          pending: pending_url
        },
        auto_return: "approved",
        statement_descriptor: "ELIXER",
        payment_methods: {
          excluded_payment_types: [],
          installments: 12
        }
      }
    end
    
    def order_items_for_preference
      order.order_items.map do |item|
        {
          id: item.product_variant_id,
          title: "#{item.product_name} - #{item.variant_name}",
          quantity: item.quantity,
          unit_price: item.unit_price.to_f,
          currency_id: "BRL"
        }
      end
    end
    
    def payer_data
      {
        name: order.user.name.split.first,
        surname: order.user.name.split[1..].join(" "),
        email: order.user.email
      }
    end
    
    def notification_url
      "#{base_url}/api/v1/webhooks/mercadopago"
    end
    
    def success_url
      "#{base_url}/orders/#{order.id}?status=success"
    end
    
    def failure_url
      "#{base_url}/orders/#{order.id}?status=failure"
    end
    
    def pending_url
      "#{base_url}/orders/#{order.id}?status=pending"
    end
    
    def base_url
      ENV.fetch("APP_URL", "http://localhost:3000")
    end
  end
end
