class AccountsController < ApplicationController
  before_action :authenticate_user!
  
  def show
    @recent_orders = current_user.orders.recent.limit(5)
    @addresses_count = current_user.addresses.count
    @wishlist_count = current_user.wishlists.first&.items_count || 0
  end
  
  def edit
    @user = current_user
  end
  
  def update
    @user = current_user
    
    if @user.update(account_params)
      redirect_to account_path, notice: "Perfil atualizado com sucesso"
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def orders
    @orders = current_user.orders.includes(:order_items, :payment).recent.page(params[:page]).per(10)
  end
  
  def wishlist
    @wishlist = current_user.wishlists.first_or_create!(name: "Minha Lista de Desejos")
    @items = @wishlist.wishlist_items.includes(product: { images_attachments: :blob })
  end
  
  private
  
  def account_params
    params.require(:user).permit(:name, :email, :phone, :avatar_url)
  end
end
