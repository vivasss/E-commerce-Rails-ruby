module Admin
  class UsersController < BaseController
    before_action :set_user, only: [:show, :edit, :update, :destroy, :toggle_active]
    
    def index
      @q = User.ransack(params[:q])
      @users = @q.result
                 .order(created_at: :desc)
                 .page(params[:page])
                 .per(20)
    end
    
    def show
      @orders = @user.orders.recent.limit(10)
      @addresses = @user.addresses
    end
    
    def edit
    end
    
    def update
      if @user.update(user_params)
        redirect_to admin_user_path(@user), notice: "Usuario atualizado"
      else
        render :edit, status: :unprocessable_entity
      end
    end
    
    def destroy
      @user.destroy
      redirect_to admin_users_path, notice: "Usuario removido"
    end
    
    def toggle_active
      @user.update(active: !@user.active)
      redirect_back fallback_location: admin_users_path,
                    notice: "Usuario #{@user.active? ? 'ativado' : 'desativado'}"
    end
    
    private
    
    def set_user
      @user = User.find(params[:id])
    end
    
    def user_params
      params.require(:user).permit(:name, :email, :phone, :role, :active)
    end
  end
end
