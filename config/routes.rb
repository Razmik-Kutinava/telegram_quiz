Rails.application.routes.draw do
  get "main/home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Telegram webhook
  post "telegram/webhook", to: "telegram_webhook#webhook"

  # API для сохранения результатов квиза
  namespace :api do
    post "quiz_sessions", to: "quiz_sessions#create"
  end

  # Админ-панель
  namespace :admin do
    get '/login', to: 'sessions#new', as: :login
    post '/login', to: 'sessions#create'
    delete '/logout', to: 'sessions#destroy', as: :logout
    
    root 'dashboard#index'
    
    resources :users, only: [:index, :show, :edit, :update, :destroy]
    resources :quiz_sessions, only: [:index, :show, :edit, :update, :destroy]
    resources :seasons
  end

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "main#home"
end
