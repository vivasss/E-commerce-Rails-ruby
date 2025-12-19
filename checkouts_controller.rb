class CheckoutsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_cart_not_empty
  before_action :load_checkout_data
  
  def show
    @step = params[:step] || "addresses"
  end
  
  def addresses
    @addresses = current_user.addresses.order(default: :desc)
    @new_address = Address.new
  end
  
  def set_addresses
    session[:checkout] ||= {}
    session[:checkout][:shipping_address_id] = params[:shipping_address_id]
    session[:checkout][:billing_address_id] = params[:billing_address_id] || params[:shipping_address_id]
    
    redirect_to shipping_checkout_path
  end
  
  def shipping
    load_addresses
    @shipping_options = Checkout::ShippingCalculatorService.new(cart: current_cart).available_methods
  end
  
  def set_shipping
    session[:checkout][:shipping_method] = params[:shipping_method]
    session[:checkout][:coupon_code] = params[:coupon_code] if params[:coupon_code].present?
    
    redirect_to payment_checkout_path
  end
  
  def payment
    load_addresses
    calculate_totals
    @available_gateways = [:stripe, :mercadopago]
  end
  
  def process_payment
    load_addresses
    
    shipping_address_data = address_to_hash(@shipping_address)
    billing_address_data = address_to_hash(@billing_address)
    
    service = Checkout::CreateOrderService.call(
      user: current_user,
      cart: current_cart,
      shipping_address: shipping_address_data,
      billing_address: billing_address_data,
      coupon_code: session.dig(:checkout, :coupon_code),
      shipping_method: session.dig(:checkout, :shipping_method),
      notes: params[:notes]
    )
    
    if service.success?
      @order = service.result
      process_gateway_payment(@order, params[:gateway])
    else
      flash[:alert] = service.errors.join(", ")
      redirect_to payment_checkout_path
    end
  end
  
  def confirmation
    @order = current_user.orders.find(params[:order_id])
    clear_checkout_session
  end
  
  private
  
  def ensure_cart_not_empty
    if current_cart.nil? || current_cart.empty?
      redirect_to cart_path, alert: "Seu carrinho esta vazio"
    end
  end
  
  def load_checkout_data
    @cart = current_cart
    @cart_items = @cart.cart_items.includes(product_variant: :product)
  end
  
  def load_addresses
    @shipping_address = current_user.addresses.find_by(id: session.dig(:checkout, :shipping_address_id))
    @billing_address = current_user.addresses.find_by(id: session.dig(:checkout, :billing_address_id))
    
    unless @shipping_address
      redirect_to addresses_checkout_path, alert: "Selecione um endereco de entrega"
    end
  end
  
  def calculate_totals
    @subtotal = @cart.subtotal
    @shipping = Checkout::ShippingCalculatorService.new(
      cart: @cart,
      method: session.dig(:checkout, :shipping_method)
    ).calculate
    
    @discount = 0
    if session.dig(:checkout, :coupon_code).present?
      coupon = Coupon.find_by("UPPER(code) = ?", session[:checkout][:coupon_code].upcase)
      @discount = coupon&.calculate_discount(@subtotal) || 0
      @coupon = coupon
    end
    
    @total = @subtotal - @discount + @shipping
  end
  
  def process_gateway_payment(order, gateway)
    case gateway&.to_sym
    when :stripe
      payment_service = Payments::StripeService.new(order)
      result = payment_service.create_payment(order.total, params[:payment_method_id])
      
      if result[:error]
        redirect_to payment_checkout_path, alert: result[:error]
      else
        redirect_to confirmation_checkout_path(order_id: order.id)
      end
      
    when :mercadopago
      payment_service = Payments::MercadopagoService.new(order)
      result = payment_service.create_payment(order.total)
      
      if result[:error]
        redirect_to payment_checkout_path, alert: result[:error]
      else
        redirect_to result[:preference]["init_point"], allow_other_host: true
      end
      
    else
      redirect_to confirmation_checkout_path(order_id: order.id)
    end
  end
  
  def address_to_hash(address)
    {
      name: address.name,
      street: address.street,
      number: address.number,
      complement: address.complement,
      neighborhood: address.neighborhood,
      city: address.city,
      state: address.state,
      postal_code: address.postal_code,
      country: address.country,
      phone: address.phone
    }
  end
  
  def clear_checkout_session
    session.delete(:checkout)
  end
end
