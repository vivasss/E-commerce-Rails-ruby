module Cart
  class UpdateItemService < BaseService
    MAX_QUANTITY = 99
    
    def initialize(cart:, variant_id:, quantity:)
      super()
      @cart = cart
      @variant_id = variant_id
      @quantity = quantity.to_i
    end
    
    def call
      find_item
      return self if failure?
      
      if @quantity <= 0
        remove_item
      else
        update_item
      end
      
      self
    end
    
    private
    
    def find_item
      @item = @cart.cart_items.find_by(product_variant_id: @variant_id)
      fail_with("Item nao encontrado no carrinho") unless @item
    end
    
    def remove_item
      @item.destroy
      succeed(nil)
    end
    
    def update_item
      if @quantity > MAX_QUANTITY
        return fail_with("Quantidade maxima permitida: #{MAX_QUANTITY}")
      end
      
      if @quantity > @item.product_variant.stock_quantity
        return fail_with("Estoque insuficiente. Disponivel: #{@item.product_variant.stock_quantity}")
      end
      
      @item.update!(quantity: @quantity)
      succeed(@item)
    end
  end
end
