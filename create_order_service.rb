module Checkout
  class CreateOrderService < BaseService
    def initialize(user:, cart:, shipping_address:, billing_address: nil, coupon_code: nil, shipping_method: nil, notes: nil)
      super()
      @user = user
      @cart = cart
      @shipping_address = shipping_address
      @billing_address = billing_address || shipping_address
      @coupon_code = coupon_code
      @shipping_method = shipping_method
      @notes = notes
    end
    
    def call
      validate_cart
      return self if failure?
      
      validate_stock
      return self if failure?
      
      validate_coupon if @coupon_code.present?
      return self if failure?
      
      ActiveRecord::Base.transaction do
        create_order
        create_order_items
        reserve_stock
        apply_coupon
        calculate_totals
        clear_cart
      end
      
      succeed(@order)
    rescue ActiveRecord::RecordInvalid => e
      fail_with(e.record.errors.full_messages.join(", "))
    end
    
    private
    
    def validate_cart
      if @cart.nil? || @cart.empty?
        fail_with("Carrinho vazio")
      end
    end
    
    def validate_stock
      @cart.cart_items.each do |item|
        unless item.in_stock?
          fail_with("#{item.product_name} - #{item.variant_name}: estoque insuficiente")
        end
      end
    end
    
    def validate_coupon
      @coupon = Coupon.find_by("UPPER(code) = ?", @coupon_code.upcase)
      
      if @coupon.nil?
        fail_with("Cupom invalido")
      elsif !@coupon.available?
        fail_with("Cupom nao disponivel")
      elsif !@coupon.valid_for_user?(@user)
        fail_with("Limite de uso do cupom atingido")
      elsif !@coupon.valid_for_amount?(@cart.subtotal)
        fail_with("Valor minimo para o cupom: R$ #{@coupon.minimum_amount}")
      end
    end
    
    def create_order
      @order = Order.new(
        user: @user,
        status: :pending,
        notes: @notes,
        coupon: @coupon,
        shipping_name: @shipping_address[:name],
        shipping_street: @shipping_address[:street],
        shipping_number: @shipping_address[:number],
        shipping_complement: @shipping_address[:complement],
        shipping_neighborhood: @shipping_address[:neighborhood],
        shipping_city: @shipping_address[:city],
        shipping_state: @shipping_address[:state],
        shipping_postal_code: @shipping_address[:postal_code],
        shipping_country: @shipping_address[:country] || "BR",
        shipping_phone: @shipping_address[:phone],
        billing_name: @billing_address[:name],
        billing_street: @billing_address[:street],
        billing_number: @billing_address[:number],
        billing_complement: @billing_address[:complement],
        billing_neighborhood: @billing_address[:neighborhood],
        billing_city: @billing_address[:city],
        billing_state: @billing_address[:state],
        billing_postal_code: @billing_address[:postal_code],
        billing_country: @billing_address[:country] || "BR",
        billing_phone: @billing_address[:phone],
        subtotal: 0,
        total: 0
      )
      @order.save!
    end
    
    def create_order_items
      @cart.cart_items.each do |cart_item|
        @order.order_items.create!(
          product_variant: cart_item.product_variant,
          product: cart_item.product_variant.product,
          product_name: cart_item.product_variant.product.name,
          variant_name: cart_item.product_variant.name,
          sku: cart_item.product_variant.sku,
          quantity: cart_item.quantity,
          unit_price: cart_item.unit_price
        )
      end
    end
    
    def reserve_stock
      @order.order_items.each do |item|
        Catalog::StockService.call(
          variant: item.product_variant,
          quantity: item.quantity,
          operation: :reserve
        )
      end
    end
    
    def apply_coupon
      return unless @coupon
      
      CouponUsage.create!(
        coupon: @coupon,
        user: @user,
        order: @order
      )
      @coupon.increment_usage!
    end
    
    def calculate_totals
      subtotal = @order.order_items.sum { |i| i.quantity * i.unit_price }
      discount = @coupon&.calculate_discount(subtotal) || 0
      shipping = calculate_shipping
      
      @order.update!(
        subtotal: subtotal,
        discount_amount: discount,
        shipping_amount: shipping,
        total: subtotal - discount + shipping
      )
    end
    
    def calculate_shipping
      ShippingCalculatorService.new(
        order: @order,
        method: @shipping_method
      ).calculate
    end
    
    def clear_cart
      @cart.clear!
    end
  end
end
