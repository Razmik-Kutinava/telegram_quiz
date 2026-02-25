#!/bin/bash
# Bash script to set Telegram webhook for Render deployment

BOT_TOKEN="8761820883:AAFUdSvQxPhLbyn2fzpFbLc2VJIbis9fgho"
WEBHOOK_URL="https://telegram-quiz-sirr.onrender.com/telegram/webhook"

echo "Setting Telegram webhook..."
echo "URL: $WEBHOOK_URL"

response=$(curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/setWebhook" \
  -F "url=${WEBHOOK_URL}")

echo "$response" | jq '.'

if echo "$response" | jq -e '.ok == true' > /dev/null; then
  echo "✅ Webhook установлен успешно!"
else
  echo "❌ Ошибка при установке webhook"
fi

echo ""
echo "Проверка webhook..."
curl -s "https://api.telegram.org/bot${BOT_TOKEN}/getWebhookInfo" | jq '.'
