module Cart
  class AddItemService < BaseService
    MAX_QUANTITY = 99
    
    def initialize(cart:, variant_id:, quantity: 1)
      super()
      @cart = cart
      @variant_id = variant_id
      @quantity = quantity.to_i
    end
    
    def call
      validate_quantity
      return self if failure?
      
      find_variant
      return self if failure?
      
      validate_stock
      return self if failure?
      
      add_or_update_item
      self
    end
    
    private
    
    def validate_quantity
      if @quantity <= 0
        fail_with("Quantidade deve ser maior que zero")
      elsif @quantity > MAX_QUANTITY
        fail_with("Quantidade maxima permitida: #{MAX_QUANTITY}")
      end
    end
    
    def find_variant
      @variant = ProductVariant.active.find_by(id: @variant_id)
      fail_with("Produto nao encontrado") unless @variant
    end
    
    def validate_stock
      existing_quantity = existing_item&.quantity || 0
      total_quantity = existing_quantity + @quantity
      
      if total_quantity > @variant.stock_quantity
        available = @variant.stock_quantity - existing_quantity
        fail_with("Estoque insuficiente. Disponivel para adicionar: #{[available, 0].max}")
      end
    end
    
    def add_or_update_item
      if existing_item
        new_quantity = existing_item.quantity + @quantity
        existing_item.update!(quantity: new_quantity)
        succeed(existing_item)
      else
        item = @cart.cart_items.create!(
          product_variant: @variant,
          quantity: @quantity,
          unit_price: @variant.price
        )
        succeed(item)
      end
    end
    
    def existing_item
      @existing_item ||= @cart.cart_items.find_by(product_variant_id: @variant_id)
    end
  end
end
