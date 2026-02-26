# Отладка Telegram Webhook

## Проблема: Бот не отвечает на /start

## Шаг 1: Проверьте что webhook настроен

Выполните команду (замените YOUR_TOKEN на ваш токен):

```bash
curl https://api.telegram.org/bot8761820883:AAFUdSvQxPhLbyn2fzpFbLc2VJIbis9fgho/getWebhookInfo
```

Должно вернуть:
```json
{
  "ok": true,
  "result": {
    "url": "https://telegram-quiz-sirr.onrender.com/telegram/webhook",
    "has_custom_certificate": false,
    "pending_update_count": 0
  }
}
```

Если `url` неправильный или пустой, настройте webhook:

```bash
curl -F "url=https://telegram-quiz-sirr.onrender.com/telegram/webhook" \
  https://api.telegram.org/bot8761820883:AAFUdSvQxPhLbyn2fzpFbLc2VJIbis9fgho/setWebhook
```

## Шаг 2: Проверьте логи в Render

1. Откройте Render Dashboard
2. Выберите ваш сервис
3. Перейдите в раздел "Logs"
4. Отправьте `/start` боту
5. В логах должно появиться:
   ```
   === WEBHOOK CALLED ===
   Method: POST
   Content-Type: application/json
   ...
   ```

Если в логах НЕТ записей "=== WEBHOOK CALLED ===" - значит webhook вообще не вызывается.

## Шаг 3: Проверьте переменные окружения

В Render Dashboard → Environment Variables должны быть:
- `TELEGRAM_BOT_TOKEN` = `8761820883:AAFUdSvQxPhLbyn2fzpFbLc2VJIbis9fgho`
- `TELEGRAM_WEB_APP_URL` = `https://telegram-quiz-sirr.onrender.com`

## Шаг 4: Проверьте что приложение работает

Откройте в браузере:
- https://telegram-quiz-sirr.onrender.com/up - должно вернуть `{"status":"ok"}`

## Шаг 5: Тестовый запрос к webhook

Попробуйте отправить тестовый запрос:

```bash
curl -X POST https://telegram-quiz-sirr.onrender.com/telegram/webhook \
  -H "Content-Type: application/json" \
  -d '{"message":{"chat":{"id":123456},"text":"/start"}}'
```

В логах Render должно появиться:
```
=== WEBHOOK CALLED ===
Message received - chat_id: 123456, text: "/start"
Processing /start command
```

## Если ничего не помогает:

1. Убедитесь что сервис перезапущен после изменений
2. Проверьте что webhook URL правильный (без лишних слешей)
3. Проверьте что токен бота правильный
4. Посмотрите полные логи в Render - там должны быть все ошибки
