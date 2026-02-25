require 'net/http'
require 'uri'
require 'json'

class TelegramWebhookController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:webhook]
  
  def webhook
    # Логируем что пришло - ВСЕГДА
    Rails.logger.info "=== WEBHOOK CALLED ==="
    Rails.logger.info "Method: #{request.method}"
    Rails.logger.info "Content-Type: #{request.content_type}"
    Rails.logger.info "Params keys: #{params.keys.inspect}"
    
    begin
      # Rails автоматически парсит JSON в params, если Content-Type правильный
      # Но также пробуем прочитать body напрямую
      data = nil
      
      # Вариант 1: Данные уже в params (Rails автоматически распарсил)
      if params[:message] || params['message'] || params[:callback_query] || params['callback_query']
        Rails.logger.info "Data found in params"
        data = params.to_unsafe_h
      else
        # Вариант 2: Читаем body и парсим вручную
        Rails.logger.info "Reading from request body"
        request.body.rewind
        body_content = request.body.read
        Rails.logger.info "Body length: #{body_content.length}"
        
        if body_content.present?
          data = JSON.parse(body_content)
          data = data.with_indifferent_access if data.is_a?(Hash)
        end
      end
      
      Rails.logger.info "Data keys: #{data&.keys&.inspect}"
      
      # Получаем message или callback_query
      message = data&.[](:message) || data&.[]('message')
      callback_query = data&.[](:callback_query) || data&.[]('callback_query')
      
      if message
        chat = message[:chat] || message['chat'] || {}
        chat_id = chat[:id] || chat['id']
        text = message[:text] || message['text']
        
        Rails.logger.info "Message received - chat_id: #{chat_id}, text: #{text.inspect}"
        
        if text == '/start'
          Rails.logger.info "Processing /start command"
          send_message(chat_id, "Привет! Это тестовое сообщение от бота 🍹")
        end
      elsif callback_query
        Rails.logger.info "Callback query received"
        callback_id = callback_query[:id] || callback_query['id']
        answer_callback_query(callback_id) if callback_id
      else
        Rails.logger.warn "No message or callback_query. Full data: #{data.inspect}"
      end
    rescue => e
      Rails.logger.error "EXCEPTION in webhook: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
    end
    
    # ВСЕГДА возвращаем 200, чтобы Telegram не повторял запрос
    head :ok
  end
  
  private
  
  def send_message(chat_id, text)
    bot_token = ENV['TELEGRAM_BOT_TOKEN']
    unless bot_token
      Rails.logger.error "TELEGRAM_BOT_TOKEN not set!"
      return
    end
    
    Rails.logger.info "Sending message to chat_id=#{chat_id}, text=#{text}"
    
    uri = URI("https://api.telegram.org/bot#{bot_token}/sendMessage")
    
    payload = {
      chat_id: chat_id,
      text: text
    }
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.path)
    request['Content-Type'] = 'application/json'
    request.body = payload.to_json
    
    response = http.request(request)
    Rails.logger.info "Telegram API response: #{response.code} #{response.body}"
    
    unless response.code.to_i == 200
      Rails.logger.error "Failed to send message: #{response.body}"
    end
  rescue => e
    Rails.logger.error "Error sending message: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
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
