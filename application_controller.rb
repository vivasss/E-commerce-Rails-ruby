class ApplicationController < ActionController::Base
  include Pagy::Backend
  
  before_action :set_current_cart
  
  helper_method :current_cart
  
  protected
  
  def current_cart
    @current_cart
  end
  
  def set_current_cart
    if user_signed_in?
      @current_cart = current_user.cart || current_user.create_cart!
      merge_session_cart if session[:cart_id].present?
    elsif session[:cart_id].present?
      @current_cart = Cart.find_by(id: session[:cart_id])
      if @current_cart.nil?
        session.delete(:cart_id)
        @current_cart = create_guest_cart
      end
    end
  end
  
  def create_guest_cart
    cart = Cart.create!(session_id: session.id.to_s)
    session[:cart_id] = cart.id
    cart
  end
  
  def ensure_cart_exists
    @current_cart ||= user_signed_in? ? current_user.create_cart! : create_guest_cart
  end
  
  def merge_session_cart
    session_cart = Cart.find_by(id: session[:cart_id])
    return unless session_cart && session_cart != @current_cart
    
    Cart::MergeCartsService.call(user: current_user, session_cart: session_cart)
    session.delete(:cart_id)
  end
  
  def authenticate_admin!
    unless user_signed_in? && current_user.admin?
      flash[:alert] = "Acesso nao autorizado"
      redirect_to root_path
    end
  end
end
