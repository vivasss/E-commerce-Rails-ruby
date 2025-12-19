module Admin
  class DashboardController < BaseController
    def index
      @stats = {
        orders_today: orders_today,
        revenue_today: revenue_today,
        orders_pending: Order.pending.count,
        orders_processing: Order.processing.count,
        low_stock_count: ProductVariant.low_stock.count,
        customers_count: User.customers.count
      }
      
      @recent_orders = Order.includes(:user, :payment)
                           .recent
                           .limit(10)
      
      @top_products = top_selling_products
      @revenue_chart = revenue_chart_data
    end
    
    private
    
    def orders_today
      Order.where(created_at: Time.current.beginning_of_day..Time.current.end_of_day)
           .where.not(status: :cancelled)
           .count
    end
    
    def revenue_today
      Order.where(created_at: Time.current.beginning_of_day..Time.current.end_of_day)
           .where.not(status: [:cancelled, :refunded])
           .sum(:total)
    end
    
    def top_selling_products
      OrderItem.joins(:order, :product)
               .where(orders: { created_at: 30.days.ago..Time.current })
               .where.not(orders: { status: [:cancelled, :refunded] })
               .group("products.id", "products.name")
               .select("products.id, products.name, SUM(order_items.quantity) as quantity_sold")
               .order("quantity_sold DESC")
               .limit(5)
    end
    
    def revenue_chart_data
      Order.where(created_at: 30.days.ago..Time.current)
           .where.not(status: [:cancelled, :refunded])
           .group("DATE(created_at)")
           .sum(:total)
           .map { |date, total| { date: date.to_s, total: total.to_f } }
    end
  end
end
