# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Создаем начальный сезон, если его нет
Season.find_or_create_by!(name: 'Весна 2025') do |season|
  season.description = 'Весенний сезон квиза НАПИ:БАР'
  season.active = true
  season.started_at = Time.current
end
