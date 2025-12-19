class AdminMailer < ApplicationMailer
  def low_stock_alert(admin, variants)
    @admin = admin
    @variants = variants
    
    mail(
      to: @admin.email,
      subject: "Alerta de Estoque Baixo - #{variants.count} produtos"
    )
  end
  
  def daily_report(admin, report_data)
    @admin = admin
    @report = report_data
    
    mail(
      to: @admin.email,
      subject: "Relatorio Diario - #{Date.current.strftime('%d/%m/%Y')}"
    )
  end
  
  def new_order(admin, order)
    @admin = admin
    @order = order
    
    mail(
      to: @admin.email,
      subject: "Novo Pedido - #{order.number}"
    )
  end
end
