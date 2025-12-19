module Reports
  class SalesReportService < BaseService
    def initialize(start_date:, end_date:, group_by: :day)
      super()
      @start_date = start_date.beginning_of_day
      @end_date = end_date.end_of_day
      @group_by = group_by
    end
    
    def call
      generate_report
      succeed(@report)
    end
    
    private
    
    def generate_report
      @report = {
        period: { start: @start_date, end: @end_date },
        summary: summary_data,
        by_period: sales_by_period,
        by_payment_method: sales_by_payment_method,
        by_status: orders_by_status,
        top_products: top_selling_products,
        top_categories: top_selling_categories
      }
    end
    
    def base_orders
      Order.where(created_at: @start_date..@end_date)
           .where.not(status: [:cancelled, :refunded])
    end
    
    def summary_data
      {
        total_orders: base_orders.count,
        total_revenue: base_orders.sum(:total),
        average_order_value: base_orders.average(:total)&.round(2) || 0,
        total_items_sold: OrderItem.joins(:order).merge(base_orders).sum(:quantity),
        total_discount: base_orders.sum(:discount_amount),
        total_shipping: base_orders.sum(:shipping_amount)
      }
    end
    
    def sales_by_period
      date_format = case @group_by
      when :hour then "%Y-%m-%d %H:00"
      when :day then "%Y-%m-%d"
      when :week then "%Y-%W"
      when :month then "%Y-%m"
      else "%Y-%m-%d"
      end
      
      base_orders
        .group("to_char(created_at, '#{date_format}')")
        .select("to_char(created_at, '#{date_format}') as period, COUNT(*) as orders_count, SUM(total) as revenue")
        .order("period")
        .map { |r| { period: r.period, orders: r.orders_count, revenue: r.revenue } }
    end
    
    def sales_by_payment_method
      Payment.joins(:order)
             .merge(base_orders)
             .where(status: :paid)
             .group(:gateway)
             .select("gateway, COUNT(*) as count, SUM(amount) as total")
             .map { |r| { gateway: r.gateway, count: r.count, total: r.total } }
    end
    
    def orders_by_status
      Order.where(created_at: @start_date..@end_date)
           .group(:status)
           .count
    end
    
    def top_selling_products(limit = 10)
      OrderItem.joins(:order, :product)
               .merge(base_orders)
               .group("products.id", "products.name")
               .select("products.id, products.name, SUM(order_items.quantity) as quantity_sold, SUM(order_items.total_price) as revenue")
               .order("quantity_sold DESC")
               .limit(limit)
               .map { |r| { id: r.id, name: r.name, quantity: r.quantity_sold, revenue: r.revenue } }
    end
    
    def top_selling_categories(limit = 5)
      OrderItem.joins(order: [], product: :category)
               .merge(base_orders)
               .group("categories.id", "categories.name")
               .select("categories.id, categories.name, SUM(order_items.quantity) as quantity_sold, SUM(order_items.total_price) as revenue")
               .order("revenue DESC")
               .limit(limit)
               .map { |r| { id: r.id, name: r.name, quantity: r.quantity_sold, revenue: r.revenue } }
    end
  end
end
