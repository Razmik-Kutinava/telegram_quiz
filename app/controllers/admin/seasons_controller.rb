module Admin
  class SeasonsController < BaseController
    before_action :set_season, only: [:show, :edit, :update, :destroy]
    
    def index
      @seasons = Season.order(created_at: :desc)
    end
    
    def show
      @quiz_sessions = @season.quiz_sessions.includes(:user).order(created_at: :desc)
    end
    
    def new
      @season = Season.new
    end
    
    def create
      @season = Season.new(season_params)
      
      if @season.save
        redirect_to admin_season_path(@season), notice: 'Сезон успешно создан'
      else
        render :new, status: :unprocessable_entity
      end
    end
    
    def edit
    end
    
    def update
      if @season.update(season_params)
        redirect_to admin_season_path(@season), notice: 'Сезон успешно обновлен'
      else
        render :edit, status: :unprocessable_entity
      end
    end
    
    def destroy
      @season.destroy
      redirect_to admin_seasons_path, notice: 'Сезон успешно удален'
    end
    
    private
    
    def set_season
      @season = Season.find(params[:id])
    end
    
    def season_params
      params.require(:season).permit(:name, :description, :active, :started_at, :ended_at)
    end
  end
end
