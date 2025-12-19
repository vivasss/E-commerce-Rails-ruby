module Payments
  class PaymentGateway
    attr_reader :order, :payment
    
    def initialize(order)
      @order = order
    end
    
    def create_payment(amount, payment_method = nil)
      raise NotImplementedError
    end
    
    def process_webhook(payload, signature = nil)
      raise NotImplementedError
    end
    
    def refund(payment, amount = nil)
      raise NotImplementedError
    end
    
    protected
    
    def create_payment_record(gateway, amount, status = :pending)
      @payment = order.payments.create!(
        gateway: gateway,
        amount: amount,
        status: status
      )
    end
  end
end
