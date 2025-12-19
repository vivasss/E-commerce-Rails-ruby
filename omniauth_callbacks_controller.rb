class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    handle_oauth("Google")
  end
  
  def facebook
    handle_oauth("Facebook")
  end
  
  def failure
    redirect_to root_path, alert: "Falha na autenticacao. Tente novamente."
  end
  
  private
  
  def handle_oauth(provider)
    @user = User.from_omniauth(request.env["omniauth.auth"])
    
    if @user.persisted?
      merge_session_cart_on_login
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: provider) if is_navigational_format?
    else
      session["devise.oauth_data"] = request.env["omniauth.auth"].except(:extra)
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join(", ")
    end
  end
  
  def merge_session_cart_on_login
    return unless session[:cart_id].present?
    
    session_cart = Cart.find_by(id: session[:cart_id])
    return unless session_cart
    
    user_cart = @user.cart || @user.create_cart!
    Cart::MergeCartsService.call(user: @user, session_cart: session_cart)
    session.delete(:cart_id)
  end
end
