module Cart
  class MergeCartsService < BaseService
    def initialize(user:, session_cart:)
      super()
      @user = user
      @session_cart = session_cart
    end
    
    def call
      return succeed(nil) unless @session_cart
      
      find_or_create_user_cart
      merge_items
      cleanup_session_cart
      
      succeed(@user_cart)
    end
    
    private
    
    def find_or_create_user_cart
      @user_cart = @user.cart || @user.create_cart!
    end
    
    def merge_items
      @session_cart.cart_items.each do |session_item|
        existing_item = @user_cart.cart_items.find_by(
          product_variant_id: session_item.product_variant_id
        )
        
        if existing_item
          new_quantity = existing_item.quantity + session_item.quantity
          max_quantity = session_item.product_variant.stock_quantity
          
          existing_item.update!(quantity: [new_quantity, max_quantity].min)
        else
          session_item.update!(cart_id: @user_cart.id)
        end
      end
    end
    
    def cleanup_session_cart
      @session_cart.reload
      @session_cart.destroy if @session_cart.cart_items.empty?
    end
  end
end
