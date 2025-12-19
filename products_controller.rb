module Admin
  class ProductsController < BaseController
    before_action :set_product, only: [:show, :edit, :update, :destroy, :toggle_active, :toggle_featured]
    
    def index
      @q = Product.ransack(params[:q])
      @products = @q.result
                    .includes(:category, :variants, images_attachments: :blob)
                    .order(created_at: :desc)
                    .page(params[:page])
                    .per(20)
    end
    
    def show
      @variants = @product.variants.ordered
    end
    
    def new
      @product = Product.new
      @product.variants.build
    end
    
    def create
      @product = Product.new(product_params)
      
      if @product.save
        redirect_to admin_product_path(@product), notice: "Produto criado com sucesso"
      else
        render :new, status: :unprocessable_entity
      end
    end
    
    def edit
    end
    
    def update
      if @product.update(product_params)
        redirect_to admin_product_path(@product), notice: "Produto atualizado"
      else
        render :edit, status: :unprocessable_entity
      end
    end
    
    def destroy
      @product.destroy
      redirect_to admin_products_path, notice: "Produto removido"
    rescue ActiveRecord::DeleteRestrictionError
      redirect_to admin_products_path, alert: "Produto possui pedidos e nao pode ser removido"
    end
    
    def toggle_active
      @product.update(active: !@product.active)
      redirect_back fallback_location: admin_products_path, 
                    notice: "Produto #{@product.active? ? 'ativado' : 'desativado'}"
    end
    
    def toggle_featured
      @product.update(featured: !@product.featured)
      redirect_back fallback_location: admin_products_path,
                    notice: "Destaque #{@product.featured? ? 'ativado' : 'removido'}"
    end
    
    private
    
    def set_product
      @product = Product.find(params[:id])
    end
    
    def product_params
      params.require(:product).permit(
        :name, :description, :short_description, :category_id,
        :base_price, :compare_at_price, :sku, :active, :featured,
        :meta_title, :meta_description, images: [],
        variants_attributes: [
          :id, :name, :sku, :price, :compare_at_price, :stock_quantity,
          :option1_name, :option1_value, :option2_name, :option2_value,
          :option3_name, :option3_value, :weight, :active, :position, :_destroy
        ]
      )
    end
  end
end
