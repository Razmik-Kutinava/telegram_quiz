require 'net/http'
require 'uri'
require 'json'
require 'securerandom'

class TelegramWebhookController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:webhook, :test, :check_env]
  
  # Логируем ВСЕ запросы к этому контроллеру
  before_action :log_request
  
  def log_request
    # Принудительно выводим в STDOUT с немедленным flush
    $stdout.puts "=" * 80
    $stdout.puts "[CONTROLLER] #{request.method} #{request.path}"
    $stdout.puts "[CONTROLLER] Time: #{Time.current}"
    $stdout.puts "[CONTROLLER] Action: #{action_name}"
    $stdout.puts "[CONTROLLER] Remote IP: #{request.remote_ip}"
    $stdout.puts "[CONTROLLER] User-Agent: #{request.user_agent}"
    $stdout.flush
    
    # Также используем Rails.logger
    Rails.logger.info "=" * 80
    Rails.logger.info "[CONTROLLER] #{request.method} #{request.path}"
    Rails.logger.info "[CONTROLLER] Time: #{Time.current}"
    Rails.logger.info "[CONTROLLER] Action: #{action_name}"
    Rails.logger.info "[CONTROLLER] Remote IP: #{request.remote_ip}"
    Rails.logger.info "[CONTROLLER] User-Agent: #{request.user_agent}"
  end
  
  # Тестовый endpoint для проверки POST запросов
  def test
    $stdout.puts "=== TEST ENDPOINT CALLED ==="
    $stdout.puts "Method: #{request.method}"
    body_content = request.body.read
    request.body.rewind
    $stdout.puts "Body: #{body_content}"
    $stdout.flush
    
    Rails.logger.info "=== TEST ENDPOINT CALLED ==="
    Rails.logger.info "Method: #{request.method}"
    Rails.logger.info "Body: #{body_content}"
    
    render json: { status: "ok", message: "POST works!", method: request.method }
  end
  
  # Endpoint для проверки переменных окружения (только для диагностики)
  def check_env
    token = ENV['TELEGRAM_BOT_TOKEN'] || ENV['TELEGRAM_TOKEN']
    token_source = if ENV['TELEGRAM_BOT_TOKEN'].present?
                     'TELEGRAM_BOT_TOKEN'
                   elsif ENV['TELEGRAM_TOKEN'].present?
                     'TELEGRAM_TOKEN'
                   else
                     'NONE'
                   end
    token_set = token.present?
    token_length = token&.length || 0
    web_app_url = ENV['TELEGRAM_WEB_APP_URL']

    $stdout.puts "=== ENV CHECK ==="
    $stdout.puts "Token found via: #{token_source}"
    $stdout.puts "Token set: #{token_set}, length: #{token_length}"
    $stdout.puts "TELEGRAM_WEB_APP_URL: #{web_app_url}"
    $stdout.flush

    render json: {
      token_set: token_set,
      token_source: token_source,
      token_length: token_length,
      web_app_url: web_app_url,
      token_preview: token_set ? "#{token[0..10]}..." : nil
    }
  end
  
  def webhook
    # Логируем что пришло - ВСЕГДА (в самом начале, до любых проверок)
    $stdout.puts "=== WEBHOOK CALLED ==="
    $stdout.flush
    Rails.logger.info "=== WEBHOOK CALLED ==="
    Rails.logger.info "Time: #{Time.current}"
    Rails.logger.info "Method: #{request.method}"
    Rails.logger.info "Path: #{request.path}"
    Rails.logger.info "Content-Type: #{request.content_type}"
    Rails.logger.info "User-Agent: #{request.user_agent}"
    Rails.logger.info "Remote IP: #{request.remote_ip}"
    Rails.logger.info "Params keys: #{params.keys.inspect}"
    
    begin
      # Пробуем получить данные из params
      data = params.to_unsafe_h
      
      # Если params пустые или нет нужных ключей, пробуем распарсить body вручную
      if data.empty? || (!data.key?("message") && !data.key?(:message) && !data.key?("callback_query") && !data.key?(:callback_query))
        $stdout.puts "[DEBUG] Params empty or no message/callback_query, trying to parse body"
        $stdout.flush
        Rails.logger.info "Params empty or no message/callback_query, trying to parse body"
        
        body_content = request.body.read
        request.body.rewind
        
        $stdout.puts "[DEBUG] Body content: #{body_content.inspect}"
        $stdout.flush
        Rails.logger.info "Body content: #{body_content.inspect}"
        
        if body_content.present?
          begin
            data = JSON.parse(body_content)
            Rails.logger.info "Parsed JSON from body: #{data.inspect}"
            $stdout.puts "[DEBUG] Parsed JSON from body: #{data.inspect}"
            $stdout.flush
          rescue JSON::ParserError => e
            Rails.logger.error "Failed to parse JSON: #{e.message}"
            $stdout.puts "[ERROR] Failed to parse JSON: #{e.message}"
            $stdout.flush
            data = {}
          end
        end
      else
        Rails.logger.info "Data from params: #{data.inspect}"
        $stdout.puts "[DEBUG] Data from params: #{data.inspect}"
        $stdout.flush
      end
      
      # Telegram обычно кладет payload в корень, без вложения в имя контроллера.
      message        = data["message"]        || data[:message]
      callback_query = data["callback_query"] || data[:callback_query]
      
      $stdout.puts "[DEBUG] Message: #{message.inspect}"
      $stdout.puts "[DEBUG] Callback query: #{callback_query.inspect}"
      $stdout.flush
      Rails.logger.info "Message: #{message.inspect}, Callback query: #{callback_query.inspect}"
      
      if message
        chat = message["chat"] || message[:chat] || {}
        chat_id = chat["id"] || chat[:id]
        text = message["text"] || message[:text]
        
        Rails.logger.info "Message received - chat_id: #{chat_id}, text: #{text.inspect}"
        $stdout.puts "[DEBUG] Message received - chat_id: #{chat_id}, text: #{text.inspect}"
        $stdout.flush
        
        if text == '/start' || text&.start_with?('/start')
          Rails.logger.info "Processing /start command for chat_id: #{chat_id}"
          $stdout.puts "[DEBUG] Processing /start command for chat_id: #{chat_id}"
          $stdout.flush

          unless chat_id
            Rails.logger.error "ERROR: chat_id is nil! Cannot send message."
            $stdout.puts "[ERROR] chat_id is nil! Cannot send message."
            $stdout.flush
          else
            web_app_url = ENV['TELEGRAM_WEB_APP_URL'] || 'https://telegram-quiz-sirr.onrender.com'

            fancy_text =
              "🌸 <b>Весенний квиз · НАПИ:БАР</b> 🌸\n\n" \
              "Узнай свой весенний вкус и получи <b>-10% на сезонное меню</b>\n" \
              "до <b>31 марта</b> в нашем баре.\n\n" \
              "Нажми <b>«Пройти квиз»</b>, чтобы начать весну ярко. 🍹"

            # Путь к логотипу
            logo_path = Rails.root.join('public', 'logo', 'logo.jpg')

            # Отправляем ВСЕ в одном сообщении: фото + текст + кнопка
            if File.exist?(logo_path)
              Rails.logger.info "Attempting to send photo with caption and button to chat_id: #{chat_id}"
              $stdout.puts "[DEBUG] Attempting to send photo with caption and button to chat_id: #{chat_id}"
              $stdout.flush

              begin
                send_photo_with_caption_and_button(
                  chat_id,
                  logo_path,
                  fancy_text,
                  "Пройти квиз",
                  web_app_url
                )
                Rails.logger.info "Photo with caption and button sent successfully"
                $stdout.puts "[SUCCESS] Photo with caption and button sent successfully"
                $stdout.flush
              rescue => e
                Rails.logger.error "Failed to send photo with caption and button: #{e.message}"
                Rails.logger.error e.backtrace.join("\n")
                $stdout.puts "[ERROR] Failed to send photo with caption and button: #{e.message}"
                $stdout.puts "[ERROR] Backtrace: #{e.backtrace.first(5).join("\n")}"
                $stdout.flush
              end
            else
              Rails.logger.warn "Logo file not found at #{logo_path}, sending text only"
              $stdout.puts "[WARN] Logo file not found at #{logo_path}, sending text only"
              $stdout.flush

              # Fallback: если нет фото, отправляем хотя бы текст с кнопкой
              send_message_with_button(chat_id, fancy_text, "Пройти квиз", web_app_url)
            end
          end
        end
      elsif callback_query
        Rails.logger.info "Callback query received"
        callback_id = callback_query["id"] || callback_query[:id]
        answer_callback_query(callback_id) if callback_id
      else
        Rails.logger.warn "No message or callback_query. Full data: #{data.inspect}"
        $stdout.puts "[WARN] No message or callback_query. Full data: #{data.inspect}"
        $stdout.flush
      end
    rescue => e
      Rails.logger.error "EXCEPTION in webhook: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      $stdout.puts "[ERROR] EXCEPTION in webhook: #{e.class} - #{e.message}"
      $stdout.puts "[ERROR] Backtrace: #{e.backtrace.first(10).join("\n")}"
      $stdout.flush
    end
    
    # ВСЕГДА возвращаем 200, чтобы Telegram не повторял запрос
    $stdout.puts "[DEBUG] Returning 200 OK"
    $stdout.flush
    head :ok
  end
  
  private

  def bot_token
    token = ENV['TELEGRAM_BOT_TOKEN'] || ENV['TELEGRAM_TOKEN']
    unless token
      $stdout.puts "[ERROR] Bot token not found! Neither TELEGRAM_BOT_TOKEN nor TELEGRAM_TOKEN is set!"
      $stdout.flush
      Rails.logger.error "Bot token not found! Neither TELEGRAM_BOT_TOKEN nor TELEGRAM_TOKEN is set!"
    end
    token
  end

  def send_message(chat_id, text)
    return unless bot_token

    $stdout.puts "[SEND] Sending message to chat_id=#{chat_id}"
    $stdout.flush
    Rails.logger.info "Sending message to chat_id=#{chat_id}, text=#{text}"

    uri = URI("https://api.telegram.org/bot#{bot_token}/sendMessage")

    payload = { chat_id: chat_id, text: text }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.path)
    request['Content-Type'] = 'application/json'
    request.body = payload.to_json

    response = http.request(request)
    $stdout.puts "[SEND] Telegram API response: #{response.code}"
    $stdout.flush
    Rails.logger.info "Telegram API response: #{response.code} #{response.body}"

    unless response.code.to_i == 200
      $stdout.puts "[ERROR] Failed to send message: #{response.body}"
      $stdout.flush
      Rails.logger.error "Failed to send message: #{response.body}"
    end
  rescue => e
    $stdout.puts "[ERROR] Error sending message: #{e.message}"
    $stdout.flush
    Rails.logger.error "Error sending message: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end

  def send_message_with_button(chat_id, text, button_text, web_app_url)
    unless bot_token
      $stdout.puts "[ERROR] Bot token is nil! Cannot send message."
      $stdout.flush
      Rails.logger.error "Bot token is nil! Cannot send message."
      return false
    end

    unless chat_id
      $stdout.puts "[ERROR] Chat ID is nil! Cannot send message."
      $stdout.flush
      Rails.logger.error "Chat ID is nil! Cannot send message."
      return false
    end

    $stdout.puts "[SEND] Sending message with button to chat_id=#{chat_id}"
    $stdout.flush
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
              web_app: { url: web_app_url }
            }
          ]
        ]
      }
    }

    $stdout.puts "[DEBUG] Payload: #{payload.inspect}"
    $stdout.flush

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 10
    request = Net::HTTP::Post.new(uri.path)
    request['Content-Type'] = 'application/json'
    request.body = payload.to_json

    response = http.request(request)
    $stdout.puts "[SEND] Telegram API response (button): #{response.code}"
    $stdout.puts "[SEND] Response body: #{response.body}"
    $stdout.flush
    Rails.logger.info "Telegram API response (button): #{response.code} #{response.body}"

    if response.code.to_i == 200
      $stdout.puts "[SUCCESS] Message sent successfully!"
      $stdout.flush
      return true
    else
      $stdout.puts "[ERROR] Failed to send button message: #{response.body}"
      $stdout.flush
      Rails.logger.error "Failed to send message with button: #{response.body}"
      return false
    end
  rescue => e
    $stdout.puts "[ERROR] Error sending message with button: #{e.message}"
    $stdout.puts "[ERROR] Exception class: #{e.class}"
    $stdout.puts "[ERROR] Backtrace: #{e.backtrace.first(10).join("\n")}"
    $stdout.flush
    Rails.logger.error "Error sending message with button: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    return false
  end

  def send_photo_with_caption_and_button(chat_id, photo_path, caption, button_text, web_app_url)
    unless bot_token
      $stdout.puts "[ERROR] Bot token is nil! Cannot send photo."
      $stdout.flush
      Rails.logger.error "Bot token is nil! Cannot send photo."
      return false
    end

    unless chat_id
      $stdout.puts "[ERROR] Chat ID is nil! Cannot send photo."
      $stdout.flush
      Rails.logger.error "Chat ID is nil! Cannot send photo."
      return false
    end

    return unless File.exist?(photo_path)

    $stdout.puts "[SEND] Sending photo with caption and button to chat_id=#{chat_id}"
    $stdout.flush
    Rails.logger.info "Sending photo with caption and button to chat_id=#{chat_id}, web_app_url=#{web_app_url}"

    uri = URI("https://api.telegram.org/bot#{bot_token}/sendPhoto")

    # Создаем multipart form data
    boundary = "----WebKitFormBoundary#{SecureRandom.hex(16)}"

    # Читаем файл
    file_content = File.binread(photo_path)

    # Формируем reply_markup (inline keyboard) как JSON
    reply_markup = {
      inline_keyboard: [
        [
          {
            text: button_text,
            web_app: { url: web_app_url }
          }
        ]
      ]
    }.to_json

    # Формируем body правильно для бинарных данных
    body = String.new.force_encoding('BINARY')

    body << "--#{boundary}\r\n"
    body << "Content-Disposition: form-data; name=\"chat_id\"\r\n\r\n"
    body << "#{chat_id}\r\n"

    body << "--#{boundary}\r\n"
    body << "Content-Disposition: form-data; name=\"caption\"\r\n\r\n"
    body << "#{caption}\r\n"

    body << "--#{boundary}\r\n"
    body << "Content-Disposition: form-data; name=\"parse_mode\"\r\n\r\n"
    body << "HTML\r\n"

    body << "--#{boundary}\r\n"
    body << "Content-Disposition: form-data; name=\"reply_markup\"\r\n\r\n"
    body << "#{reply_markup}\r\n"

    body << "--#{boundary}\r\n"
    body << "Content-Disposition: form-data; name=\"photo\"; filename=\"logo.jpg\"\r\n"
    body << "Content-Type: image/jpeg\r\n\r\n"
    body << file_content
    body << "\r\n"

    body << "--#{boundary}--\r\n"

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 10
    request = Net::HTTP::Post.new(uri.path)
    request['Content-Type'] = "multipart/form-data; boundary=#{boundary}"
    request.body = body

    response = http.request(request)
    $stdout.puts "[SEND] Telegram API response (photo+caption+button): #{response.code}"
    $stdout.puts "[SEND] Response body: #{response.body}"
    $stdout.flush
    Rails.logger.info "Telegram API response (photo+caption+button): #{response.code} #{response.body}"

    if response.code.to_i == 200
      $stdout.puts "[SUCCESS] Photo with caption and button sent successfully!"
      $stdout.flush
      return true
    else
      $stdout.puts "[ERROR] Failed to send photo with caption and button: #{response.body}"
      $stdout.flush
      Rails.logger.error "Failed to send photo with caption and button: #{response.body}"
      return false
    end
  rescue => e
    $stdout.puts "[ERROR] Error sending photo with caption and button: #{e.message}"
    $stdout.puts "[ERROR] Exception class: #{e.class}"
    $stdout.puts "[ERROR] Backtrace: #{e.backtrace.first(10).join("\n")}"
    $stdout.flush
    Rails.logger.error "Error sending photo with caption and button: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    return false
  end

  def send_photo_simple(chat_id, photo_path)
    return unless bot_token
    return unless File.exist?(photo_path)

    $stdout.puts "[SEND] Sending photo to chat_id=#{chat_id}"
    $stdout.flush
    Rails.logger.info "Sending photo to chat_id=#{chat_id}, path=#{photo_path}"

    uri = URI("https://api.telegram.org/bot#{bot_token}/sendPhoto")

    # Используем более простой подход с правильным multipart
    boundary = "----WebKitFormBoundary#{SecureRandom.hex(16)}"

    # Читаем файл
    file_content = File.binread(photo_path)

    # Формируем body правильно для бинарных данных - создаем бинарную строку сразу
    body = String.new.force_encoding('BINARY')

    body << "--#{boundary}\r\n"
    body << "Content-Disposition: form-data; name=\"chat_id\"\r\n\r\n"
    body << "#{chat_id}\r\n"

    body << "--#{boundary}\r\n"
    body << "Content-Disposition: form-data; name=\"photo\"; filename=\"logo.jpg\"\r\n"
    body << "Content-Type: image/jpeg\r\n\r\n"
    body << file_content
    body << "\r\n"

    body << "--#{boundary}--\r\n"

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.path)
    request['Content-Type'] = "multipart/form-data; boundary=#{boundary}"
    request.body = body

    response = http.request(request)
    $stdout.puts "[SEND] Telegram API response (photo): #{response.code}"
    $stdout.flush
    Rails.logger.info "Telegram API response (photo): #{response.code} #{response.body}"

    unless response.code.to_i == 200
      $stdout.puts "[ERROR] Failed to send photo: #{response.body}"
      $stdout.flush
      Rails.logger.error "Failed to send photo: #{response.body}"
    end
  rescue => e
    $stdout.puts "[ERROR] Error sending photo: #{e.message}"
    $stdout.flush
    Rails.logger.error "Error sending photo: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end

  def answer_callback_query(callback_query_id, text = nil)
    return unless bot_token

    uri = URI("https://api.telegram.org/bot#{bot_token}/answerCallbackQuery")
    params = { callback_query_id: callback_query_id }
    params[:text] = text if text

    Net::HTTP.post_form(uri, params)
  rescue => e
    Rails.logger.error "Error answering callback query: #{e.message}"
  end
end
