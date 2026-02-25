require 'net/http'
require 'uri'
require 'json'

class TelegramWebhookController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:webhook]
  
  def webhook
    message = params[:message]
    callback_query = params[:callback_query]
    
    if message
      chat_id = message[:chat][:id]
      text = message[:text]
      
      # Обработка команд
      case text
      when '/start'
        # Создаем или находим пользователя
        if message[:from]
          user_data = {
            id: message[:from][:id] || message[:from]['id'],
            username: message[:from][:username] || message[:from]['username'],
            first_name: message[:from][:first_name] || message[:from]['first_name'],
            last_name: message[:from][:last_name] || message[:from]['last_name'],
            language_code: (message[:from][:language_code] || message[:from]['language_code'] || 'ru')
          }
          
          begin
            User.find_or_create_from_telegram(user_data)
          rescue => e
            Rails.logger.error "Error creating user: #{e.message}"
            Rails.logger.error e.backtrace.join("\n")
          end
        end
        
        send_message_with_button(chat_id, 
          "Добро пожаловать в квиз НАПИ:БАР! 🍹\n\nНажмите на кнопку ниже, чтобы начать квиз и узнать свой идеальный коктейль.",
          "Открыть квиз",
          ENV['TELEGRAM_WEB_APP_URL'] || "https://scutiform-pushed-malorie.ngrok-free.dev"
        )
      else
        # Можно добавить другую логику
      end
    elsif callback_query
      # Обработка callback query (если будут inline кнопки)
      chat_id = callback_query[:message][:chat][:id]
      answer_callback_query(callback_query[:id])
    end
    
    head :ok
  end
  
  private
  
  def send_message(chat_id, text)
    bot_token = ENV['TELEGRAM_BOT_TOKEN']
    return unless bot_token
    
    uri = URI("https://api.telegram.org/bot#{bot_token}/sendMessage")
    Net::HTTP.post_form(uri, {
      chat_id: chat_id,
      text: text,
      parse_mode: 'HTML'
    })
  rescue => e
    Rails.logger.error "Error sending message: #{e.message}"
  end
  
  def send_message_with_button(chat_id, text, button_text, web_app_url)
    bot_token = ENV['TELEGRAM_BOT_TOKEN']
    return unless bot_token
    
    uri = URI("https://api.telegram.org/bot#{bot_token}/sendMessage")
    
    payload = {
      chat_id: chat_id,
      text: text,
      parse_mode: 'HTML',
      reply_markup: {
        inline_keyboard: [
          [
            {
              text: button_text,
              web_app: {
                url: web_app_url
              }
            }
          ]
        ]
      }
    }
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.path)
    request['Content-Type'] = 'application/json'
    request.body = payload.to_json
    
    http.request(request)
  rescue => e
    Rails.logger.error "Error sending message with button: #{e.message}"
  end
  
  def answer_callback_query(callback_query_id, text = nil)
    bot_token = ENV['TELEGRAM_BOT_TOKEN']
    return unless bot_token
    
    uri = URI("https://api.telegram.org/bot#{bot_token}/answerCallbackQuery")
    params = { callback_query_id: callback_query_id }
    params[:text] = text if text
    
    Net::HTTP.post_form(uri, params)
  rescue => e
    Rails.logger.error "Error answering callback query: #{e.message}"
  end
end
