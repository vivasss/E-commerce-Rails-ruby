module Admin
  class BaseController < ApplicationController
    before_action :authenticate_admin!
    
    layout "admin"
    
    private
    
    def authenticate_admin!
      unless user_signed_in? && current_user.admin?
        flash[:alert] = "Acesso restrito a administradores"
        redirect_to root_path
      end
    end
  end
end
