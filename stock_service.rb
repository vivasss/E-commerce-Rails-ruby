module Catalog
  class StockService < BaseService
    def initialize(variant:, quantity:, operation:)
      super()
      @variant = variant
      @quantity = quantity
      @operation = operation
    end
    
    def call
      case @operation
      when :reserve
        reserve_stock
      when :release
        release_stock
      when :adjust
        adjust_stock
      else
        fail_with("Operacao invalida")
      end
      
      self
    end
    
    private
    
    def reserve_stock
      if @variant.stock_quantity < @quantity
        return fail_with("Estoque insuficiente. Disponivel: #{@variant.stock_quantity}")
      end
      
      @variant.decrement!(:stock_quantity, @quantity)
      succeed(@variant)
    end
    
    def release_stock
      @variant.increment!(:stock_quantity, @quantity)
      succeed(@variant)
    end
    
    def adjust_stock
      @variant.update!(stock_quantity: @quantity)
      succeed(@variant)
    end
  end
end
