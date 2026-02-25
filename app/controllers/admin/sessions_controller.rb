module Admin
  class SessionsController < ApplicationController
    layout 'admin'
    skip_before_action :verify_authenticity_token, only: [:create]
    
    def new
      redirect_to admin_root_path if admin_signed_in?
    end
    
    def create
      admin_password = ENV['ADMIN_PASSWORD'] || 'admin123'
      
      if params[:password] == admin_password
        session[:admin_authenticated] = true
        redirect_to admin_root_path, notice: 'Вы успешно вошли в систему'
      else
        flash.now[:alert] = 'Неверный пароль'
        render :new, status: :unprocessable_entity
      end
    end
    
    def destroy
      session[:admin_authenticated] = nil
      redirect_to admin_login_path, notice: 'Вы вышли из системы'
    end
    
    helper_method :admin_signed_in?
    
    private
    
    def admin_signed_in?
      session[:admin_authenticated] == true
    end
  end
end
