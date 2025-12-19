module Api
  module V1
    class WebhooksController < BaseController
      skip_before_action :set_current_cart
      
      def stripe
        payload = request.body.read
        signature = request.env["HTTP_STRIPE_SIGNATURE"]
        
        order = find_order_from_stripe_payload(payload, signature)
        return render json: { error: "Order not found" }, status: :not_found unless order
        
        service = Payments::StripeService.new(order)
        result = service.process_webhook(payload, signature)
        
        if result[:error]
          render json: { error: result[:error] }, status: :bad_request
        else
          render json: { received: true }
        end
      end
      
      def mercadopago
        order = find_order_from_mercadopago_payload(params)
        return render json: { error: "Order not found" }, status: :not_found unless order
        
        service = Payments::MercadopagoService.new(order)
        result = service.process_webhook(params.to_unsafe_h)
        
        if result[:error]
          render json: { error: result[:error] }, status: :bad_request
        else
          render json: { received: true }
        end
      end
      
      private
      
      def find_order_from_stripe_payload(payload, signature)
        begin
          event = Stripe::Webhook.construct_event(
            payload,
            signature,
            Rails.configuration.stripe[:webhook_secret]
          )
          
          payment_intent = event.data.object
          payment = Payment.find_by(gateway_payment_id: payment_intent.id)
          payment&.order
        rescue Stripe::SignatureVerificationError
          nil
        end
      end
      
      def find_order_from_mercadopago_payload(params)
        return nil unless params[:type] == "payment"
        
        sdk = Mercadopago::SDK.new(ENV["MERCADOPAGO_ACCESS_TOKEN"])
        result = sdk.payment.get(params.dig(:data, :id))
        
        return nil unless result[:status] == 200
        
        payment_id = result[:response]["external_reference"]
        Payment.find_by(id: payment_id)&.order
      end
    end
  end
end
