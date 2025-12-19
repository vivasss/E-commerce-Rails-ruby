module Admin
  class CategoriesController < BaseController
    before_action :set_category, only: [:show, :edit, :update, :destroy, :toggle_active]
    
    def index
      @categories = Category.includes(:parent, :children)
                           .order(position: :asc, name: :asc)
    end
    
    def show
      @products = @category.products.includes(:variants).page(params[:page]).per(20)
    end
    
    def new
      @category = Category.new
    end
    
    def create
      @category = Category.new(category_params)
      
      if @category.save
        redirect_to admin_categories_path, notice: "Categoria criada"
      else
        render :new, status: :unprocessable_entity
      end
    end
    
    def edit
    end
    
    def update
      if @category.update(category_params)
        redirect_to admin_categories_path, notice: "Categoria atualizada"
      else
        render :edit, status: :unprocessable_entity
      end
    end
    
    def destroy
      @category.destroy
      redirect_to admin_categories_path, notice: "Categoria removida"
    rescue ActiveRecord::DeleteRestrictionError
      redirect_to admin_categories_path, alert: "Categoria possui produtos e nao pode ser removida"
    end
    
    def toggle_active
      @category.update(active: !@category.active)
      redirect_back fallback_location: admin_categories_path,
                    notice: "Categoria #{@category.active? ? 'ativada' : 'desativada'}"
    end
    
    def reorder
      params[:positions].each do |id, position|
        Category.find(id).update(position: position)
      end
      
      render json: { success: true }
    end
    
    private
    
    def set_category
      @category = Category.find(params[:id])
    end
    
    def category_params
      params.require(:category).permit(
        :name, :description, :parent_id, :position, :active,
        :meta_title, :meta_description, :image
      )
    end
  end
end
