module Admin
  class ReviewsController < BaseController
    before_action :set_review, only: [:approve, :reject, :destroy]
    
    def index
      @q = Review.ransack(params[:q])
      @reviews = @q.result
                   .includes(:user, :product)
                   .order(created_at: :desc)
                   .page(params[:page])
                   .per(20)
      
      @pending_count = Review.pending.count
    end
    
    def approve
      @review.approve!
      redirect_back fallback_location: admin_reviews_path, notice: "Avaliacao aprovada"
    end
    
    def reject
      @review.reject!
      redirect_back fallback_location: admin_reviews_path, notice: "Avaliacao rejeitada"
    end
    
    def destroy
      @review.destroy
      redirect_to admin_reviews_path, notice: "Avaliacao removida"
    end
    
    private
    
    def set_review
      @review = Review.find(params[:id])
    end
  end
end
