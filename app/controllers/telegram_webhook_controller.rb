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
        # Простое тестовое сообщение
        send_message(chat_id, "Привет! Это тестовое сообщение от бота 🍹")
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
