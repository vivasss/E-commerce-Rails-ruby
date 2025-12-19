class OrderMailer < ApplicationMailer
  def confirmation(order)
    @order = order
    @user = order.user
    @order_items = order.order_items.includes(product_variant: :product)
    
    mail(
      to: @user.email,
      subject: "Pedido #{@order.number} confirmado"
    )
  end
  
  def shipped(order)
    @order = order
    @user = order.user
    @shipment = order.shipment
    
    mail(
      to: @user.email,
      subject: "Seu pedido #{@order.number} foi enviado"
    )
  end
  
  def delivered(order)
    @order = order
    @user = order.user
    
    mail(
      to: @user.email,
      subject: "Seu pedido #{@order.number} foi entregue"
    )
  end
  
  def cancelled(order)
    @order = order
    @user = order.user
    
    mail(
      to: @user.email,
      subject: "Pedido #{@order.number} cancelado"
    )
  end
end
