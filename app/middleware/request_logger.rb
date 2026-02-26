class RequestLogger
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    
    # Логируем ВСЕ запросы, особенно POST на /telegram/webhook
    if request.path == '/telegram/webhook' || request.post?
      Rails.logger.info "=" * 80
      Rails.logger.info "[REQUEST_LOGGER] #{request.request_method} #{request.path}"
      Rails.logger.info "[REQUEST_LOGGER] Time: #{Time.current}"
      Rails.logger.info "[REQUEST_LOGGER] Content-Type: #{request.content_type}"
      Rails.logger.info "[REQUEST_LOGGER] User-Agent: #{request.user_agent}"
      Rails.logger.info "[REQUEST_LOGGER] Remote IP: #{request.ip}"
      Rails.logger.info "[REQUEST_LOGGER] Host: #{request.host}"
      
      # Читаем body если есть
      if request.body
        body = request.body.read
        request.body.rewind
        Rails.logger.info "[REQUEST_LOGGER] Body length: #{body.length}"
        Rails.logger.info "[REQUEST_LOGGER] Body preview: #{body[0..500]}" if body.present?
      end
      Rails.logger.info "=" * 80
    end
    
    @app.call(env)
  end
end
