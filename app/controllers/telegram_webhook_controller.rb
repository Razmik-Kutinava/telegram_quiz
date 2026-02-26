require 'net/http'
require 'uri'
require 'json'

class TelegramWebhookController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:webhook]
  
  def webhook
    # Логируем что пришло - ВСЕГДА (в самом начале, до любых проверок)
    Rails.logger.info "=== WEBHOOK CALLED ==="
    Rails.logger.info "Time: #{Time.current}"
    Rails.logger.info "Method: #{request.method}"
    Rails.logger.info "Path: #{request.path}"
    Rails.logger.info "Content-Type: #{request.content_type}"
    Rails.logger.info "User-Agent: #{request.user_agent}"
    Rails.logger.info "Remote IP: #{request.remote_ip}"
    Rails.logger.info "Params keys: #{params.keys.inspect}"
    
    # Читаем body ДО любых проверок
    request.body.rewind
    raw_body = request.body.read
    Rails.logger.info "Raw body length: #{raw_body.length}"
    Rails.logger.info "Raw body (first 500 chars): #{raw_body[0..500]}" if raw_body.present?
    
    begin
      # Парсим данные из body (Telegram всегда отправляет JSON в body)
      data = nil
      
      if raw_body.present?
        begin
          data = JSON.parse(raw_body)
          data = data.with_indifferent_access if data.is_a?(Hash)
          Rails.logger.info "Successfully parsed JSON from body"
        rescue JSON::ParserError => e
          Rails.logger.error "Failed to parse JSON: #{e.message}"
          Rails.logger.error "Body content: #{raw_body}"
        end
      end
      
      # Если не получилось из body, пробуем params (на случай если Rails распарсил)
      if data.nil? && (params[:message] || params['message'] || params[:callback_query] || params['callback_query'])
        Rails.logger.info "Data found in params (fallback)"
        data = params.to_unsafe_h
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
        
        if text == '/start' || text&.start_with?('/start')
          Rails.logger.info "Processing /start command"
          web_app_url = ENV['TELEGRAM_WEB_APP_URL'] || 'https://telegram-quiz-sirr.onrender.com'
          send_message_with_button(
            chat_id,
            "Привет! 🍹\n\nУзнай, какой ты коктейль этой весной!",
            "Открыть квиз",
            web_app_url
          )
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
    unless bot_token
      Rails.logger.error "TELEGRAM_BOT_TOKEN not set!"
      return
    end
    
    Rails.logger.info "Sending message with button to chat_id=#{chat_id}, web_app_url=#{web_app_url}"
    
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
    
    response = http.request(request)
    Rails.logger.info "Telegram API response (button): #{response.code} #{response.body}"
    
    unless response.code.to_i == 200
      Rails.logger.error "Failed to send message with button: #{response.body}"
    end
  rescue => e
    Rails.logger.error "Error sending message with button: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
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
