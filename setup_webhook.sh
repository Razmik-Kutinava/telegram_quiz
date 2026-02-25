#!/bin/bash

# Скрипт для настройки Telegram Webhook
# Использование: ./setup_webhook.sh YOUR_APP_URL

BOT_TOKEN="8761820883:AAFUdSvQxPhLbyn2fzpFbLc2VJIbis9fgho"

if [ -z "$1" ]; then
    echo "Использование: ./setup_webhook.sh YOUR_APP_URL"
    echo "Пример: ./setup_webhook.sh https://telegram-quiz.onrender.com"
    exit 1
fi

APP_URL="$1"
WEBHOOK_URL="${APP_URL}/telegram/webhook"

echo "Настраиваю webhook для бота..."
echo "URL приложения: $APP_URL"
echo "Webhook URL: $WEBHOOK_URL"

response=$(curl -s -F "url=$WEBHOOK_URL" "https://api.telegram.org/bot${BOT_TOKEN}/setWebhook")

echo ""
echo "Ответ от Telegram API:"
echo "$response" | python3 -m json.tool 2>/dev/null || echo "$response"

if echo "$response" | grep -q '"ok":true'; then
    echo ""
    echo "✅ Webhook успешно настроен!"
    echo ""
    echo "Теперь обновите Mini App URL в BotFather:"
    echo "1. Откройте @BotFather в Telegram"
    echo "2. Отправьте /myapps"
    echo "3. Выберите вашего бота"
    echo "4. Отправьте /editapp"
    echo "5. Укажите URL: $APP_URL"
else
    echo ""
    echo "❌ Ошибка при настройке webhook"
    exit 1
fi
