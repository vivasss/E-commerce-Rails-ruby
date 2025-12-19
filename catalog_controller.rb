class CatalogController < ApplicationController
  def index
    @categories = Category.active.root_categories.ordered.includes(:children)
    @featured_products = Product.active.featured.includes(:variants, images_attachments: :blob).limit(8)
    
    service = Catalog::ProductSearchService.call(search_params)
    @products = service.result
    
    @pagy, @products = pagy_array(@products.to_a) if @products.respond_to?(:to_a)
  end
  
  def search
    service = Catalog::ProductSearchService.call(search_params)
    
    if service.success?
      @products = service.result
      @pagy, @products = pagy_array(@products.to_a)
    else
      @products = []
      flash.now[:alert] = service.errors.join(", ")
    end
  end
  
  def category
    @category = Category.friendly.find(params[:slug])
    
    service = Catalog::ProductSearchService.call(
      search_params.merge(category_id: @category.id)
    )
    
    @products = service.result
    @pagy, @products = pagy_array(@products.to_a)
    @subcategories = @category.children.active.ordered
  end
  
  private
  
  def search_params
    params.permit(:q, :category_id, :min_price, :max_price, :in_stock, :sort, :page, :per_page)
  end
end
