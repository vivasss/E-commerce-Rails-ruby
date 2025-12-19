module Admin
  class OrdersController < BaseController
    before_action :set_order, only: [:show, :confirm, :process_order, :ship, :deliver, :cancel]
    
    def index
      @q = Order.ransack(params[:q])
      @orders = @q.result
                  .includes(:user, :payment, :shipment)
                  .order(created_at: :desc)
                  .page(params[:page])
                  .per(20)
      
      @status_counts = Order.group(:status).count
    end
    
    def show
      @order_items = @order.order_items.includes(product_variant: :product)
      @payment = @order.payment
      @shipment = @order.shipment
    end
    
    def confirm
      if @order.may_confirm? && @order.confirm!
        redirect_to admin_order_path(@order), notice: "Pedido confirmado"
      else
        redirect_to admin_order_path(@order), alert: "Nao foi possivel confirmar o pedido"
      end
    end
    
    def process_order
      if @order.may_process_order? && @order.process_order!
        redirect_to admin_order_path(@order), notice: "Pedido em processamento"
      else
        redirect_to admin_order_path(@order), alert: "Nao foi possivel processar o pedido"
      end
    end
    
    def ship
      tracking_number = params[:tracking_number]
      carrier = params[:carrier]
      
      if tracking_number.blank?
        return redirect_to admin_order_path(@order), alert: "Codigo de rastreamento obrigatorio"
      end
      
      shipment = @order.shipment || @order.create_shipment!
      shipment.mark_as_shipped!(tracking_number, carrier)
      
      redirect_to admin_order_path(@order), notice: "Pedido enviado"
    end
    
    def deliver
      if @order.may_deliver?
        @order.shipment&.mark_as_delivered!
        redirect_to admin_order_path(@order), notice: "Pedido entregue"
      else
        redirect_to admin_order_path(@order), alert: "Nao foi possivel marcar como entregue"
      end
    end
    
    def cancel
      if @order.may_cancel?
        @order.update(cancellation_reason: params[:reason])
        @order.cancel!
        redirect_to admin_order_path(@order), notice: "Pedido cancelado"
      else
        redirect_to admin_order_path(@order), alert: "Nao foi possivel cancelar o pedido"
      end
    end
    
    private
    
    def set_order
      @order = Order.find(params[:id])
    end
  end
end
