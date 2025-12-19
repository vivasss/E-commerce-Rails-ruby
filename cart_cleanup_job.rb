class CartCleanupJob < ApplicationJob
  queue_as :low_priority
  
  def perform
    Cart.expired.guest_carts.find_each(&:destroy)
  end
end
