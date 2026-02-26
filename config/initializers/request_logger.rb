# Загружаем middleware для логирования запросов
require_relative '../../lib/request_logger'

Rails.application.config.middleware.use RequestLogger
