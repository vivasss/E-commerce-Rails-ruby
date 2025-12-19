class StockAlertJob < ApplicationJob
  queue_as :low_priority
  
  LOW_STOCK_THRESHOLD = 10
  
  def perform
    low_stock_variants = ProductVariant.low_stock(LOW_STOCK_THRESHOLD)
                                       .includes(:product)
    
    return if low_stock_variants.empty?
    
    admin_users = User.admins.where(active: true)
    
    admin_users.find_each do |admin|
      AdminMailer.low_stock_alert(admin, low_stock_variants.to_a).deliver_later
    end
  end
end
