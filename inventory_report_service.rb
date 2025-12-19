module Reports
  class InventoryReportService < BaseService
    def initialize(category_id: nil, low_stock_threshold: 10)
      super()
      @category_id = category_id
      @low_stock_threshold = low_stock_threshold
    end
    
    def call
      generate_report
      succeed(@report)
    end
    
    private
    
    def generate_report
      @report = {
        summary: summary_data,
        low_stock: low_stock_items,
        out_of_stock: out_of_stock_items,
        by_category: stock_by_category,
        stock_value: calculate_stock_value
      }
    end
    
    def base_variants
      scope = ProductVariant.joins(:product).where(products: { active: true })
      
      if @category_id.present?
        category = Category.find(@category_id)
        category_ids = [category.id] + category.descendants.map(&:id)
        scope = scope.where(products: { category_id: category_ids })
      end
      
      scope
    end
    
    def summary_data
      {
        total_products: Product.active.count,
        total_variants: base_variants.count,
        total_stock_units: base_variants.sum(:stock_quantity),
        low_stock_count: base_variants.where("stock_quantity <= ? AND stock_quantity > 0", @low_stock_threshold).count,
        out_of_stock_count: base_variants.where(stock_quantity: 0).count
      }
    end
    
    def low_stock_items
      base_variants
        .where("product_variants.stock_quantity <= ? AND product_variants.stock_quantity > 0", @low_stock_threshold)
        .includes(:product)
        .order(:stock_quantity)
        .limit(50)
        .map do |v|
          {
            id: v.id,
            sku: v.sku,
            product_name: v.product.name,
            variant_name: v.name,
            stock: v.stock_quantity,
            price: v.price
          }
        end
    end
    
    def out_of_stock_items
      base_variants
        .where(stock_quantity: 0)
        .includes(:product)
        .limit(50)
        .map do |v|
          {
            id: v.id,
            sku: v.sku,
            product_name: v.product.name,
            variant_name: v.name,
            price: v.price
          }
        end
    end
    
    def stock_by_category
      Category.active
              .includes(:products)
              .map do |category|
                variants = ProductVariant.joins(:product).where(products: { category_id: category.id })
                {
                  id: category.id,
                  name: category.name,
                  products_count: category.products.active.count,
                  total_stock: variants.sum(:stock_quantity),
                  stock_value: variants.sum("stock_quantity * price")
                }
              end
              .sort_by { |c| -c[:stock_value] }
    end
    
    def calculate_stock_value
      base_variants.sum("stock_quantity * price")
    end
  end
end
