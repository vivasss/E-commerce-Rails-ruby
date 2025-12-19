class Users::RegistrationsController < Devise::RegistrationsController
  protected
  
  def after_sign_up_path_for(resource)
    merge_carts(resource)
    super
  end
  
  def after_update_path_for(resource)
    account_path
  end
  
  private
  
  def sign_up_params
    params.require(:user).permit(:name, :email, :phone, :password, :password_confirmation)
  end
  
  def account_update_params
    params.require(:user).permit(:name, :email, :phone, :password, :password_confirmation, :current_password)
  end
  
  def merge_carts(user)
    return unless session[:cart_id].present?
    
    session_cart = Cart.find_by(id: session[:cart_id])
    return unless session_cart
    
    Cart::MergeCartsService.call(user: user, session_cart: session_cart)
    session.delete(:cart_id)
  end
end
