require 'net/http'
require 'uri'
require 'json'

class TelegramWebhookController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:webhook]
  
  def webhook
    # Логируем что пришло
    Rails.logger.info "=== WEBHOOK CALLED ==="
    Rails.logger.info "Params: #{params.inspect}"
    Rails.logger.info "Request content type: #{request.content_type}"
    
    # Читаем body один раз
    request.body.rewind
    body_content = request.body.read
    Rails.logger.info "Request body: #{body_content.inspect}"
    
    # Пробуем получить данные из params (Rails может автоматически парсить JSON)
    # или из request.body
    data = params.to_unsafe_h
    
    # Если в params нет данных, пробуем парсить body
    if data.empty? || (!data['message'] && !data[:message] && !data['callback_query'] && !data[:callback_query])
      begin
        Rails.logger.info "Parsing body: #{body_content}"
        if body_content.present?
          data = JSON.parse(body_content)
          data = data.with_indifferent_access if data.is_a?(Hash)
        end
      rescue => e
        Rails.logger.error "Error parsing webhook data: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        return head :ok # Все равно возвращаем 200, чтобы Telegram не повторял запрос
      end
    end
    
    Rails.logger.info "Parsed data: #{data.inspect}"
    
    # Получаем message или callback_query
    message = data[:message] || data['message']
    callback_query = data[:callback_query] || data['callback_query']
    
    if message
      chat = message[:chat] || message['chat'] || {}
      chat_id = chat[:id] || chat['id']
      text = message[:text] || message['text']
      
      Rails.logger.info "Message: chat_id=#{chat_id}, text=#{text.inspect}"
      
      if text == '/start'
        Rails.logger.info "Processing /start command for chat_id=#{chat_id}"
        send_message(chat_id, "Привет! Это тестовое сообщение от бота 🍹")
      else
        Rails.logger.info "Unknown command: #{text}"
      end
    elsif callback_query
      Rails.logger.info "Callback query received"
      callback_id = callback_query[:id] || callback_query['id']
      answer_callback_query(callback_id) if callback_id
    else
      Rails.logger.warn "No message or callback_query found. Data keys: #{data.keys.inspect}"
    end
    
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
