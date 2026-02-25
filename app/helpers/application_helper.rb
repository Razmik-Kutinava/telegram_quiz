module ApplicationHelper
  def safe_asset_path(asset_name, fallback: nil)
    begin
      asset_path(asset_name)
    rescue => e
      # Обрабатываем любые ошибки при получении asset path
      Rails.logger.debug "Asset not found: #{asset_name} - #{e.class}: #{e.message}" if defined?(Rails)
      fallback || ''
    end
  end
end
