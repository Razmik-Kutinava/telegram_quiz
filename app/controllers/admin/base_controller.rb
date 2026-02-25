module Admin
  class BaseController < ApplicationController
    before_action :authenticate_admin!
    
    layout 'admin'
    
    private
    
    def authenticate_admin!
      unless admin_signed_in?
        redirect_to admin_login_path, alert: 'Пожалуйста, войдите в систему'
      end
    end
    
    def admin_signed_in?
      session[:admin_authenticated] == true
    end
    
    helper_method :admin_signed_in?
  end
end
