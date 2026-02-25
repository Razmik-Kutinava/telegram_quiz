module Admin
  class DashboardController < BaseController
    def index
      @total_users = User.count
      @total_sessions = QuizSession.count
      @total_seasons = Season.count
      @today_sessions = QuizSession.where('created_at >= ?', Time.current.beginning_of_day).count
      
      # Статистика по результатам
      @results_stats = QuizSession.group(:result_label)
                                   .count
                                   .sort_by { |_, count| -count }
                                   .first(10)
      
      # Статистика по дням (последние 7 дней) - упрощенная версия
      @daily_stats = QuizSession.where('created_at >= ?', 7.days.ago)
                                 .group("DATE(created_at)")
                                 .count
      
      # Последние сессии
      @recent_sessions = QuizSession.includes(:user, :season)
                                     .order(created_at: :desc)
                                     .limit(10)
    end
  end
end
