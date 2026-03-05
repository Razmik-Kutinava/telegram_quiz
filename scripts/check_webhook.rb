#!/usr/bin/env ruby
# Скрипт для проверки и установки Telegram webhook

require 'net/http'
require 'uri'
require 'json'

token = ENV['TELEGRAM_BOT_TOKEN'] || ENV['TELEGRAM_TOKEN']
webhook_url = ENV['TELEGRAM_WEBHOOK_URL'] || ENV['TELEGRAM_WEB_APP_URL'] || 'https://razmik-kutinava-telegram-quiz-d64a.twc1.net'

if webhook_url && !webhook_url.end_with?('/telegram/webhook')
  webhook_url = "#{webhook_url.chomp('/')}/telegram/webhook"
end

puts "=" * 80
puts "Telegram Webhook Checker"
puts "=" * 80
puts "Token: #{token ? token[0..10] + '...' : 'NOT SET'}"
puts "Webhook URL: #{webhook_url}"
puts "=" * 80

unless token
  puts "ERROR: TELEGRAM_BOT_TOKEN or TELEGRAM_TOKEN not set!"
  exit 1
end

# Проверяем текущий webhook
puts "\n1. Checking current webhook..."
uri = URI("https://api.telegram.org/bot#{token}/getWebhookInfo")
response = Net::HTTP.get_response(uri)
result = JSON.parse(response.body)

if result['ok']
  webhook_info = result['result']
  puts "Current webhook URL: #{webhook_info['url'] || 'NOT SET'}"
  puts "Pending updates: #{webhook_info['pending_update_count'] || 0}"
  puts "Last error date: #{webhook_info['last_error_date'] || 'N/A'}"
  puts "Last error message: #{webhook_info['last_error_message'] || 'N/A'}"
  
  if webhook_info['url'] != webhook_url
    puts "\n⚠️  Webhook URL mismatch!"
    puts "   Current: #{webhook_info['url']}"
    puts "   Expected: #{webhook_url}"
    
    puts "\n2. Setting webhook to correct URL..."
    set_uri = URI("https://api.telegram.org/bot#{token}/setWebhook")
    set_uri.query = URI.encode_www_form(url: webhook_url)
    set_response = Net::HTTP.get_response(set_uri)
    set_result = JSON.parse(set_response.body)
    
    if set_result['ok']
      puts "✅ Webhook successfully set!"
      puts "   URL: #{webhook_url}"
    else
      puts "❌ Failed to set webhook: #{set_result['description']}"
      exit 1
    end
  else
    puts "\n✅ Webhook URL is correct!"
  end
else
  puts "❌ Failed to get webhook info: #{result['description']}"
  exit 1
end

puts "\n" + "=" * 80
puts "Done!"
puts "=" * 80
