class WishlistsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_wishlist
  
  def show
    @items = @wishlist.wishlist_items.includes(product: [:variants, images_attachments: :blob])
  end
  
  def add_item
    product = Product.find(params[:product_id])
    
    if @wishlist.add_product(product)
      respond_to do |format|
        format.html { redirect_back fallback_location: product_path(product), notice: "Adicionado a lista de desejos" }
        format.json { render json: { success: true } }
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: product_path(product), alert: "Produto ja esta na lista" }
        format.json { render json: { success: false }, status: :unprocessable_entity }
      end
    end
  end
  
  def remove_item
    product = Product.find(params[:product_id])
    @wishlist.remove_product(product)
    
    respond_to do |format|
      format.html { redirect_to wishlist_path, notice: "Removido da lista de desejos" }
      format.json { render json: { success: true } }
    end
  end
  
  def move_to_cart
    product = Product.find(params[:product_id])
    variant = product.default_variant
    
    if variant
      ensure_cart_exists
      Cart::AddItemService.call(cart: current_cart, variant_id: variant.id, quantity: 1)
      @wishlist.remove_product(product)
      
      redirect_to cart_path, notice: "Produto movido para o carrinho"
    else
      redirect_to wishlist_path, alert: "Produto indisponivel"
    end
  end
  
  private
  
  def set_wishlist
    @wishlist = current_user.wishlists.first_or_create!(name: "Minha Lista de Desejos")
  end
end
