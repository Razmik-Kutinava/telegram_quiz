module Admin
  class QuizSessionsController < BaseController
    before_action :set_quiz_session, only: [:show, :edit, :update, :destroy]
    
    def index
      @quiz_sessions = QuizSession.includes(:user, :season)
                                   .order(created_at: :desc)
      
      # Простая пагинация без gem
      per_page = 20
      @page = (params[:page] || 1).to_i
      @quiz_sessions = @quiz_sessions.limit(per_page).offset((@page - 1) * per_page)
      
      if params[:search].present?
        @quiz_sessions = @quiz_sessions.joins(:user).where(
          "users.first_name LIKE ? OR users.username LIKE ? OR result_label LIKE ?",
          "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%"
        )
      end
      
      if params[:season_id].present?
        @quiz_sessions = @quiz_sessions.where(season_id: params[:season_id])
      end
    end
    
    def show
    end
    
    def edit
    end
    
    def update
      if @quiz_session.update(quiz_session_params)
        redirect_to admin_quiz_session_path(@quiz_session), notice: 'Сессия успешно обновлена'
      else
        render :edit, status: :unprocessable_entity
      end
    end
    
    def destroy
      @quiz_session.destroy
      redirect_to admin_quiz_sessions_path, notice: 'Сессия успешно удалена'
    end
    
    private
    
    def set_quiz_session
      @quiz_session = QuizSession.find(params[:id])
    end
    
    def quiz_session_params
      params.require(:quiz_session).permit(:result_type, :result_label, :source, :started_at, :completed_at, :season_id)
    end
  end
end
