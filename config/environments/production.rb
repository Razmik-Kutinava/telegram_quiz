require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # Отключаем force_ssl для Timeweb, так как они проксируют через HTTP
  # config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Change to "debug" to log everything (including potentially personally-identifiable information!).
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Replace the default in-process memory cache store with a durable alternative.
  config.cache_store = :solid_cache_store

  # Replace the default in-process and non-durable queuing backend for Active Job.
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Set host to be used by links generated in mailer templates.
  # Поддержка Render, Vercel и Timeweb
  render_host = ENV['RENDER_EXTERNAL_HOSTNAME'] || (ENV['RENDER_EXTERNAL_URL']&.gsub(/^https?:\/\//, ''))
  vercel_host = ENV['VERCEL_URL']&.gsub(/^https?:\/\//, '')
  timeweb_host = ENV['TIMEWEB_URL']&.gsub(/^https?:\/\//, '') || ENV['TIMEWEB_HOSTNAME'] || ENV['TELEGRAM_WEB_APP_URL']&.gsub(/^https?:\/\//, '')
  app_host = render_host || vercel_host || timeweb_host || ENV['APP_HOST'] || "example.com"
  config.action_mailer.default_url_options = { 
    host: app_host
  }

  # Specify outgoing SMTP server. Remember to add smtp/* credentials via bin/rails credentials:edit.
  # config.action_mailer.smtp_settings = {
  #   user_name: Rails.application.credentials.dig(:smtp, :user_name),
  #   password: Rails.application.credentials.dig(:smtp, :password),
  #   address: "smtp.example.com",
  #   port: 587,
  #   authentication: :plain
  # }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Enable DNS rebinding protection and other `Host` header attacks.
  # Поддержка Render, Vercel и Timeweb хостов
  if ENV['RENDER_EXTERNAL_HOSTNAME']
    config.hosts << ENV['RENDER_EXTERNAL_HOSTNAME']
  end
  if ENV['VERCEL_URL']
    config.hosts << ENV['VERCEL_URL'].gsub(/^https?:\/\//, '')
  end
  if ENV['TIMEWEB_URL'] || ENV['TIMEWEB_HOSTNAME'] || ENV['TELEGRAM_WEB_APP_URL']
    timeweb_host = ENV['TIMEWEB_URL']&.gsub(/^https?:\/\//, '') || ENV['TIMEWEB_HOSTNAME'] || ENV['TELEGRAM_WEB_APP_URL']&.gsub(/^https?:\/\//, '')
    config.hosts << timeweb_host if timeweb_host
  end
  config.hosts << /.*\.onrender\.com/
  config.hosts << /.*\.vercel\.app/
  config.hosts << /.*\.timeweb\.cloud/
  config.hosts << /.*\.timeweb\.ru/
  config.hosts << /.*\.twc1\.net/  # Timeweb Cloud домены
  
  # Skip DNS rebinding protection для всех запросов через балансировщик Timeweb
  # Timeweb использует reverse proxy, поэтому разрешаем все запросы
  config.host_authorization = { 
    exclude: ->(request) { 
      # Разрешаем все запросы через балансировщик Timeweb
      request.remote_ip&.start_with?("172.") || # Docker внутренняя сеть
      request.remote_ip&.start_with?("10.") ||  # Docker внутренняя сеть
      request.remote_ip == "127.0.0.1" ||       # localhost
      request.host&.end_with?(".twc1.net") ||   # Timeweb Cloud домены
      request.host&.end_with?(".timeweb.cloud") || # Timeweb Cloud домены
      request.host&.end_with?(".timeweb.ru") || # Timeweb домены
      request.path == "/up" ||                  # Health check
      request.path.start_with?("/telegram/")    # Webhook endpoints
    } 
  }
end
