class Users::SessionsController < Devise::SessionsController
  def create
    super do |resource|
      merge_carts(resource) if resource.persisted?
    end
  end
  
  private
  
  def merge_carts(user)
    return unless session[:cart_id].present?
    
    session_cart = Cart.find_by(id: session[:cart_id])
    return unless session_cart
    
    Cart::MergeCartsService.call(user: user, session_cart: session_cart)
    session.delete(:cart_id)
  end
end
