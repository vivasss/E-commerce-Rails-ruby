module Admin
  class CouponsController < BaseController
    before_action :set_coupon, only: [:show, :edit, :update, :destroy, :toggle_active]
    
    def index
      @coupons = Coupon.order(created_at: :desc).page(params[:page]).per(20)
    end
    
    def show
      @usages = @coupon.coupon_usages.includes(:user, :order).recent.limit(20)
    end
    
    def new
      @coupon = Coupon.new
    end
    
    def create
      @coupon = Coupon.new(coupon_params)
      
      if @coupon.save
        redirect_to admin_coupons_path, notice: "Cupom criado"
      else
        render :new, status: :unprocessable_entity
      end
    end
    
    def edit
    end
    
    def update
      if @coupon.update(coupon_params)
        redirect_to admin_coupons_path, notice: "Cupom atualizado"
      else
        render :edit, status: :unprocessable_entity
      end
    end
    
    def destroy
      @coupon.destroy
      redirect_to admin_coupons_path, notice: "Cupom removido"
    end
    
    def toggle_active
      @coupon.update(active: !@coupon.active)
      redirect_back fallback_location: admin_coupons_path,
                    notice: "Cupom #{@coupon.active? ? 'ativado' : 'desativado'}"
    end
    
    private
    
    def set_coupon
      @coupon = Coupon.find(params[:id])
    end
    
    def coupon_params
      params.require(:coupon).permit(
        :code, :discount_type, :discount_value, :minimum_amount,
        :maximum_discount, :usage_limit, :per_user_limit,
        :starts_at, :expires_at, :active, :description
      )
    end
  end
end
