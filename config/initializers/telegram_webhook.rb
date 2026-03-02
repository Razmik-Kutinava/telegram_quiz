# Ensure Telegram webhook is configured on app boot. This makes the bot
# registration more resilient when the app is redeployed.

Rails.application.config.after_initialize do
  token = ENV['TELEGRAM_BOT_TOKEN'] || ENV['TELEGRAM_TOKEN']
  # prefer explicit webhook URL, otherwise build from TELEGRAM_WEB_APP_URL or default host
  if ENV['TELEGRAM_WEBHOOK_URL'].present?
    webhook_url = ENV['TELEGRAM_WEBHOOK_URL']
  else
    base = ENV['TELEGRAM_WEB_APP_URL'] || ENV['APP_BASE_URL'] || ''
    # if we don't yet know a base URL (e.g. during assets precompile), skip setting webhook
    webhook_url = base.present? ? "#{base.chomp('/')}" + "/telegram/webhook" : nil
  end

  if token.present?
    if webhook_url.present?
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
      Rails.logger.warn "Webhook URL could not be determined; skipping setWebhook"
      $stdout.puts "[INIT] Webhook URL could not be determined; skipping setWebhook"
    end
  else
    Rails.logger.warn "Telegram token missing, cannot set webhook in initializer"
    $stdout.puts "[INIT] Telegram token missing, cannot set webhook in initializer"
  end
end
