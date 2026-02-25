module Api
  class QuizSessionsController < ApplicationController
    skip_before_action :verify_authenticity_token
    
    def create
      # Получаем данные пользователя из Telegram WebApp
      telegram_user = params[:telegram_user]
      
      unless telegram_user
        return render json: { error: 'Telegram user data required' }, status: :bad_request
      end
      
      # Находим или создаем пользователя
      user = User.find_or_create_from_telegram(telegram_user)
      
      unless user
        return render json: { error: 'Не удалось создать пользователя' }, status: :bad_request
      end
      
      # Получаем текущий сезон
      season = Season.current || Season.create!(name: 'Default Season', active: true)
      
      # Проверяем, не прошел ли уже пользователь квиз в этом сезоне
      existing_session = QuizSession.find_by(user_id: user.id, season_id: season.id)
      
      if existing_session
        return render json: { 
          error: 'Вы уже проходили квиз в этом сезоне',
          session: existing_session.as_json(include: [:user, :season])
        }, status: :conflict
      end
      
      # Создаем новую сессию
      quiz_session = QuizSession.new(
        user: user,
        season: season,
        result_type: params[:result_type] || 'cocktail',
        result_label: params[:result_label],
        answers: params[:answers] || {},
        started_at: params[:started_at] ? Time.parse(params[:started_at]) : Time.current,
        completed_at: Time.current,
        source: params[:source] || 'organic'
      )
      
      if quiz_session.save
        render json: { 
          success: true,
          session: quiz_session.as_json(include: [:user, :season])
        }, status: :created
      else
        render json: { 
          error: 'Не удалось сохранить результат',
          errors: quiz_session.errors.full_messages
        }, status: :unprocessable_entity
      end
    rescue => e
      Rails.logger.error "Error creating quiz session: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { error: 'Внутренняя ошибка сервера' }, status: :internal_server_error
    end
  end
end
