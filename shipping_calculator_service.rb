module Checkout
  class ShippingCalculatorService
    SHIPPING_METHODS = {
      standard: { name: "Padrao", base_cost: 15.00, per_kg: 2.00, days: "7-10" },
      express: { name: "Expresso", base_cost: 25.00, per_kg: 4.00, days: "3-5" },
      same_day: { name: "Mesmo Dia", base_cost: 45.00, per_kg: 6.00, days: "0-1" }
    }.freeze
    
    FREE_SHIPPING_THRESHOLD = 200.00
    
    def initialize(order: nil, cart: nil, method: nil, postal_code: nil)
      @order = order
      @cart = cart
      @method = (method || :standard).to_sym
      @postal_code = postal_code
    end
    
    def calculate
      return 0 if free_shipping?
      
      method_config = SHIPPING_METHODS[@method] || SHIPPING_METHODS[:standard]
      base_cost = method_config[:base_cost]
      weight_cost = total_weight * method_config[:per_kg]
      
      (base_cost + weight_cost).round(2)
    end
    
    def available_methods
      SHIPPING_METHODS.map do |key, config|
        {
          id: key,
          name: config[:name],
          cost: calculate_for_method(key),
          delivery_days: config[:days]
        }
      end
    end
    
    private
    
    def free_shipping?
      subtotal >= FREE_SHIPPING_THRESHOLD
    end
    
    def subtotal
      if @order
        @order.subtotal
      elsif @cart
        @cart.subtotal
      else
        0
      end
    end
    
    def total_weight
      items = @order&.order_items || @cart&.cart_items || []
      
      items.sum do |item|
        variant = item.respond_to?(:product_variant) ? item.product_variant : item.product_variant
        (variant.weight || 0.5) * item.quantity
      end
    end
    
    def calculate_for_method(method_key)
      original_method = @method
      @method = method_key
      result = calculate
      @method = original_method
      result
    end
  end
end
