class RequestLogger
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    
    # Логируем ВСЕ POST запросы и запросы на /telegram/webhook
    should_log = request.path == '/telegram/webhook' || request.path == '/telegram/test' || request.post?
    
    if should_log
      begin
        # Используем STDOUT напрямую для гарантии, что логи будут видны
        STDOUT.puts "=" * 80
        STDOUT.puts "[REQUEST_LOGGER] #{request.request_method} #{request.path}"
        STDOUT.puts "[REQUEST_LOGGER] Time: #{Time.current}"
        STDOUT.puts "[REQUEST_LOGGER] Content-Type: #{request.content_type}"
        STDOUT.puts "[REQUEST_LOGGER] User-Agent: #{request.user_agent}"
        STDOUT.puts "[REQUEST_LOGGER] Remote IP: #{request.ip}"
        STDOUT.puts "[REQUEST_LOGGER] Host: #{request.host}"
        
        # Также используем Rails.logger если доступен
        if defined?(Rails) && Rails.logger
          Rails.logger.info "=" * 80
          Rails.logger.info "[REQUEST_LOGGER] #{request.request_method} #{request.path}"
          Rails.logger.info "[REQUEST_LOGGER] Time: #{Time.current}"
          Rails.logger.info "[REQUEST_LOGGER] Content-Type: #{request.content_type}"
          Rails.logger.info "[REQUEST_LOGGER] User-Agent: #{request.user_agent}"
          Rails.logger.info "[REQUEST_LOGGER] Remote IP: #{request.ip}"
          Rails.logger.info "[REQUEST_LOGGER] Host: #{request.host}"
        end
        
        # Читаем body если есть
        if request.body
          body = request.body.read
          request.body.rewind
          if body && body.length > 0
            STDOUT.puts "[REQUEST_LOGGER] Body length: #{body.length}"
            STDOUT.puts "[REQUEST_LOGGER] Body preview: #{body[0..500]}"
            if defined?(Rails) && Rails.logger
              Rails.logger.info "[REQUEST_LOGGER] Body length: #{body.length}"
              Rails.logger.info "[REQUEST_LOGGER] Body preview: #{body[0..500]}"
            end
          end
        end
        
        STDOUT.puts "=" * 80
        Rails.logger.info "=" * 80 if defined?(Rails) && Rails.logger
      rescue => e
        STDOUT.puts "[REQUEST_LOGGER] ERROR: #{e.message}"
        STDOUT.puts e.backtrace.join("\n") if e.backtrace
      end
    end
    
    @app.call(env)
  end
end
