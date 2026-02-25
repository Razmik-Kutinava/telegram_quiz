module Admin
  class UsersController < BaseController
    before_action :set_user, only: [:show, :edit, :update, :destroy]
    
    def index
      @users = User.includes(:quiz_sessions)
                   .order(created_at: :desc)
      
      # Простая пагинация без gem
      per_page = 20
      @page = (params[:page] || 1).to_i
      @users = @users.limit(per_page).offset((@page - 1) * per_page)
      
      if params[:search].present?
        @users = @users.where(
          "first_name LIKE ? OR username LIKE ? OR telegram_id LIKE ?",
          "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%"
        )
      end
    end
    
    def show
      @quiz_sessions = @user.quiz_sessions.includes(:season).order(created_at: :desc)
    end
    
    def edit
    end
    
    def update
      if @user.update(user_params)
        redirect_to admin_user_path(@user), notice: 'Пользователь успешно обновлен'
      else
        render :edit, status: :unprocessable_entity
      end
    end
    
    def destroy
      @user.destroy
      redirect_to admin_users_path, notice: 'Пользователь успешно удален'
    end
    
    private
    
    def set_user
      @user = User.find(params[:id])
    end
    
    def user_params
      params.require(:user).permit(:username, :first_name, :last_name, :language_code)
    end
  end
end
