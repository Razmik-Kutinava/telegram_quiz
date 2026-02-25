require 'net/http'
require 'uri'
require 'json'

class TelegramWebhookController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:webhook]
  
  def webhook
    # Парсим JSON из request body
    begin
      data = JSON.parse(request.body.read)
      data = data.with_indifferent_access
    rescue => e
      Rails.logger.error "Error parsing webhook data: #{e.message}"
      return head :bad_request
    end
    
    Rails.logger.info "Webhook received: #{data.inspect}"
    
    message = data[:message] || data['message']
    callback_query = data[:callback_query] || data['callback_query']
    
    if message
      chat_id = message[:chat]&.[](:id) || message['chat']&.[]('id')
      text = message[:text] || message['text']
      
      Rails.logger.info "Message received: chat_id=#{chat_id}, text=#{text}"
      
      # Обработка команд
      if text == '/start'
        Rails.logger.info "Processing /start command"
        send_message(chat_id, "Привет! Это тестовое сообщение от бота 🍹")
      end
    elsif callback_query
      # Обработка callback query (если будут inline кнопки)
      chat_id = callback_query[:message]&.[](:chat)&.[](:id) || callback_query['message']&.[]('chat')&.[]('id')
      callback_id = callback_query[:id] || callback_query['id']
      answer_callback_query(callback_id)
    else
      Rails.logger.warn "Unknown webhook data format: #{data.keys.inspect}"
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
