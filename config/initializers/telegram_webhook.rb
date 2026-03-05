# Ensure Telegram webhook is configured on app boot. This makes the bot
# registration more resilient when the app is redeployed.

require 'net/http'
require 'uri'
require 'json'

Rails.application.config.after_initialize do
  # Принудительно выводим в STDOUT с flush
  $stdout.puts "=" * 80
  $stdout.puts "[INIT] Starting Telegram webhook setup..."
  $stdout.flush
  
  token = ENV['TELEGRAM_BOT_TOKEN'] || ENV['TELEGRAM_TOKEN']
  $stdout.puts "[INIT] Token present: #{token.present?}"
  $stdout.puts "[INIT] TELEGRAM_BOT_TOKEN: #{ENV['TELEGRAM_BOT_TOKEN'] ? 'SET' : 'NOT SET'}"
  $stdout.puts "[INIT] TELEGRAM_TOKEN: #{ENV['TELEGRAM_TOKEN'] ? 'SET' : 'NOT SET'}"
  $stdout.flush
  
  # prefer explicit webhook URL, otherwise build from TELEGRAM_WEB_APP_URL, TIMEWEB_URL or default host
  if ENV['TELEGRAM_WEBHOOK_URL'].present?
    webhook_url = ENV['TELEGRAM_WEBHOOK_URL']
    $stdout.puts "[INIT] Using TELEGRAM_WEBHOOK_URL: #{webhook_url}"
  else
    base = ENV['TELEGRAM_WEB_APP_URL'] || ENV['TIMEWEB_URL'] || ENV['APP_BASE_URL'] || ''
    $stdout.puts "[INIT] TELEGRAM_WEB_APP_URL: #{ENV['TELEGRAM_WEB_APP_URL'] || 'NOT SET'}"
    $stdout.puts "[INIT] TIMEWEB_URL: #{ENV['TIMEWEB_URL'] || 'NOT SET'}"
    $stdout.puts "[INIT] APP_BASE_URL: #{ENV['APP_BASE_URL'] || 'NOT SET'}"
    $stdout.puts "[INIT] Base URL: #{base.inspect}"
    # if we don't yet know a base URL (e.g. during assets precompile), skip setting webhook
    webhook_url = base.present? ? "#{base.chomp('/')}" + "/telegram/webhook" : nil
    $stdout.puts "[INIT] Constructed webhook URL: #{webhook_url.inspect}"
  end
  $stdout.flush

  if token.present?
    if webhook_url.present?
      begin
        # Используем POST запрос с JSON body (правильный способ для Telegram API)
        uri = URI("https://api.telegram.org/bot#{token}/setWebhook")
        
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.read_timeout = 10
        
        request = Net::HTTP::Post.new(uri.path)
        request['Content-Type'] = 'application/json'
        request.body = { url: webhook_url }.to_json
        
        response = http.request(request)
        result = JSON.parse(response.body) rescue nil

        if result && result['ok']
          Rails.logger.info "Telegram webhook successfully set: #{webhook_url}"
          $stdout.puts "[INIT] ✅ Telegram webhook successfully set: #{webhook_url}"
        else
          Rails.logger.error "Failed to set Telegram webhook: #{response.code} #{response.body}"
          $stdout.puts "[INIT] ❌ Failed to set Telegram webhook: #{response.code} #{response.body}"
        end
      rescue => e
        Rails.logger.error "Failed to set Telegram webhook: #{e.message}"
        Rails.logger.error e.backtrace.first(5).join("\n")
        $stdout.puts "[INIT] ❌ Failed to set Telegram webhook: #{e.message}"
        $stdout.puts "[INIT] Backtrace: #{e.backtrace.first(5).join("\n")}"
      end
    else
      Rails.logger.warn "Webhook URL could not be determined; skipping setWebhook"
      $stdout.puts "[INIT] ⚠️  Webhook URL could not be determined; skipping setWebhook"
    end
  else
    Rails.logger.warn "Telegram token missing, cannot set webhook in initializer"
    $stdout.puts "[INIT] ⚠️  Telegram token missing, cannot set webhook in initializer"
  end
end
