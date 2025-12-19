module Reports
  class CustomerReportService < BaseService
    def initialize(start_date: nil, end_date: nil)
      super()
      @start_date = start_date&.beginning_of_day
      @end_date = end_date&.end_of_day || Time.current
    end
    
    def call
      generate_report
      succeed(@report)
    end
    
    private
    
    def generate_report
      @report = {
        summary: summary_data,
        new_customers: new_customers_by_period,
        top_customers: top_customers,
        by_location: customers_by_location,
        retention: retention_data
      }
    end
    
    def summary_data
      {
        total_customers: User.customers.count,
        active_customers: User.customers.joins(:orders).distinct.count,
        new_customers_period: new_customers_count,
        average_orders_per_customer: average_orders,
        average_lifetime_value: average_ltv
      }
    end
    
    def new_customers_count
      scope = User.customers
      scope = scope.where(created_at: @start_date..@end_date) if @start_date
      scope.count
    end
    
    def average_orders
      total_orders = Order.where.not(status: :cancelled).count
      total_customers = User.customers.joins(:orders).distinct.count
      return 0 if total_customers.zero?
      (total_orders.to_f / total_customers).round(2)
    end
    
    def average_ltv
      User.customers
          .joins(:orders)
          .where.not(orders: { status: [:cancelled, :refunded] })
          .group("users.id")
          .select("users.id, SUM(orders.total) as total_spent")
          .map(&:total_spent)
          .then { |values| values.empty? ? 0 : (values.sum / values.size).round(2) }
    end
    
    def new_customers_by_period
      scope = User.customers
      scope = scope.where(created_at: @start_date..@end_date) if @start_date
      
      scope.group("DATE(created_at)")
           .count
           .map { |date, count| { date: date, count: count } }
           .sort_by { |r| r[:date] }
    end
    
    def top_customers(limit = 10)
      User.customers
          .joins(:orders)
          .where.not(orders: { status: [:cancelled, :refunded] })
          .group("users.id", "users.name", "users.email")
          .select("users.id, users.name, users.email, COUNT(orders.id) as orders_count, SUM(orders.total) as total_spent")
          .order("total_spent DESC")
          .limit(limit)
          .map do |u|
            {
              id: u.id,
              name: u.name,
              email: u.email,
              orders: u.orders_count,
              total_spent: u.total_spent
            }
          end
    end
    
    def customers_by_location
      Address.where(address_type: :shipping, default: true)
             .joins(:user)
             .where(users: { role: :customer })
             .group(:state)
             .count
             .map { |state, count| { state: state, count: count } }
             .sort_by { |r| -r[:count] }
    end
    
    def retention_data
      total_customers = User.customers.joins(:orders).distinct.count
      repeat_customers = User.customers
                             .joins(:orders)
                             .group("users.id")
                             .having("COUNT(orders.id) > 1")
                             .count
                             .keys
                             .count
      
      {
        total_with_orders: total_customers,
        repeat_customers: repeat_customers,
        retention_rate: total_customers.zero? ? 0 : ((repeat_customers.to_f / total_customers) * 100).round(2)
      }
    end
  end
end
