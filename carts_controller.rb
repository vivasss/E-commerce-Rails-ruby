module Api
  module V1
    class CartsController < BaseController
      before_action :ensure_cart, only: [:show, :add_item, :update_item, :remove_item, :clear]
      
      def show
        render json: {
          cart: serialize_cart(@cart)
        }
      end
      
      def add_item
        service = Cart::AddItemService.call(
          cart: @cart,
          variant_id: params[:variant_id],
          quantity: params[:quantity] || 1
        )
        
        if service.success?
          render json: { success: true, cart: serialize_cart(@cart.reload) }
        else
          render json: { success: false, errors: service.errors }, status: :unprocessable_entity
        end
      end
      
      def update_item
        service = Cart::UpdateItemService.call(
          cart: @cart,
          variant_id: params[:variant_id],
          quantity: params[:quantity]
        )
        
        if service.success?
          render json: { success: true, cart: serialize_cart(@cart.reload) }
        else
          render json: { success: false, errors: service.errors }, status: :unprocessable_entity
        end
      end
      
      def remove_item
        @cart.remove_item(ProductVariant.find(params[:variant_id]))
        render json: { success: true, cart: serialize_cart(@cart.reload) }
      end
      
      def clear
        @cart.clear!
        render json: { success: true }
      end
      
      private
      
      def ensure_cart
        @cart = current_cart
        
        unless @cart
          session_id = request.headers["X-Cart-Session"] || SecureRandom.uuid
          @cart = Cart.create!(session_id: session_id)
          response.headers["X-Cart-Session"] = session_id
        end
      end
      
      def serialize_cart(cart)
        {
          id: cart.id,
          items_count: cart.items_count,
          total_items: cart.total_items,
          subtotal: cart.subtotal.to_f,
          items: cart.cart_items.includes(product_variant: :product).map { |item| serialize_cart_item(item) }
        }
      end
      
      def serialize_cart_item(item)
        {
          id: item.id,
          variant_id: item.product_variant_id,
          product_name: item.product_name,
          variant_name: item.variant_name,
          quantity: item.quantity,
          unit_price: item.unit_price.to_f,
          total_price: item.total_price.to_f,
          in_stock: item.in_stock?,
          available_stock: item.available_stock
        }
      end
    end
  end
end
