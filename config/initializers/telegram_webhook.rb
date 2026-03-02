# Ensure Telegram webhook is configured on app boot. This makes the bot
# registration more resilient when the app is redeployed.

Rails.application.config.after_initialize do
  token = ENV['TELEGRAM_BOT_TOKEN'] || ENV['TELEGRAM_TOKEN']
  # prefer explicit webhook URL, otherwise fall back to web app url or generated root
  webhook_url = ENV['TELEGRAM_WEBHOOK_URL'] || (ENV['TELEGRAM_WEB_APP_URL'] ? "#{ENV['TELEGRAM_WEB_APP_URL'].chomp('/')}" : "#{Rails.application.routes.url_helpers.root_url.chomp('/')}") + "/telegram/webhook"

  if token.present?
    begin
      uri = URI("https://api.telegram.org/bot#{token}/setWebhook")
      params = { url: webhook_url }
      uri.query = URI.encode_www_form(params)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(uri)
      response = http.request(request)

      Rails.logger.info "Telegram webhook set response: #{response.code} #{response.body}"
      $stdout.puts "[INIT] Telegram webhook set response: #{response.code} #{response.body}"
    rescue => e
      Rails.logger.error "Failed to set Telegram webhook: #{e.message}"
      $stdout.puts "[INIT] Failed to set Telegram webhook: #{e.message}"
    end
  else
    Rails.logger.warn "Telegram token missing, cannot set webhook in initializer"
    $stdout.puts "[INIT] Telegram token missing, cannot set webhook in initializer"
  end
end
