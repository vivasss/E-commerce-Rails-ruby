class OrderConfirmationJob < ApplicationJob
  queue_as :mailers
  
  def perform(order_id)
    order = Order.find_by(id: order_id)
    return unless order
    
    OrderMailer.confirmation(order).deliver_now
    
    order.order_items.each do |item|
      item.product.increment!(:total_sold, item.quantity)
    end
  end
end
