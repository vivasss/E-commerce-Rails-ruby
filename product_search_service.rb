module Catalog
  class ProductSearchService < BaseService
    def initialize(params = {})
      super
      @params = params
      @scope = Product.active.includes(:category, :variants, images_attachments: :blob)
    end
    
    def call
      apply_search
      apply_category_filter
      apply_price_filter
      apply_stock_filter
      apply_sorting
      apply_pagination
      
      succeed(@scope)
    end
    
    private
    
    def apply_search
      return if @params[:q].blank?
      @scope = @scope.search_by_term(@params[:q])
    end
    
    def apply_category_filter
      return if @params[:category_id].blank?
      
      category = Category.find_by(id: @params[:category_id])
      return unless category
      
      category_ids = [category.id] + category.descendants.map(&:id)
      @scope = @scope.where(category_id: category_ids)
    end
    
    def apply_price_filter
      if @params[:min_price].present?
        @scope = @scope.where("base_price >= ?", @params[:min_price].to_d)
      end
      
      if @params[:max_price].present?
        @scope = @scope.where("base_price <= ?", @params[:max_price].to_d)
      end
    end
    
    def apply_stock_filter
      return unless @params[:in_stock] == "true" || @params[:in_stock] == true
      @scope = @scope.in_stock
    end
    
    def apply_sorting
      case @params[:sort]
      when "price_asc"
        @scope = @scope.order(base_price: :asc)
      when "price_desc"
        @scope = @scope.order(base_price: :desc)
      when "newest"
        @scope = @scope.order(created_at: :desc)
      when "popular"
        @scope = @scope.order(total_sold: :desc)
      when "rating"
        @scope = @scope.order(average_rating: :desc)
      else
        @scope = @scope.order(created_at: :desc)
      end
    end
    
    def apply_pagination
      page = (@params[:page] || 1).to_i
      per_page = (@params[:per_page] || 20).to_i.clamp(1, 100)
      
      @scope = @scope.limit(per_page).offset((page - 1) * per_page)
    end
  end
end
