# Отладка проблемы с webhook

## Проблема
В логах нет записей о том, что webhook был установлен, и нет запросов от Telegram к `/telegram/webhook`.

## Что было добавлено

1. **Подробное логирование инициализации** - теперь в логах будет видно, что происходит при установке webhook
2. **Endpoint для проверки webhook** - `/telegram/check_webhook` - показывает текущий статус webhook в Telegram

## Что нужно сделать СЕЙЧАС

### ШАГ 1: Перезапустить приложение в Timeweb Cloud

1. Зайди в Timeweb Cloud Dashboard
2. Найди проект `telegram-quiz`
3. Нажми **"Restart"** или **"Redeploy"**
4. Дождись завершения перезапуска (2-5 минут)

### ШАГ 2: Проверить логи после перезапуска

После перезапуска в логах ДОЛЖНЫ появиться записи:

```
================================================================================
[INIT] Starting Telegram webhook setup...
[INIT] Token present: true
[INIT] TELEGRAM_BOT_TOKEN: SET
[INIT] TELEGRAM_WEB_APP_URL: https://razmik-kutinava-telegram-quiz-d64a.twc1.net
[INIT] Constructed webhook URL: https://razmik-kutinava-telegram-quiz-d64a.twc1.net/telegram/webhook
[INIT] ✅ Telegram webhook successfully set: https://razmik-kutinava-telegram-quiz-d64a.twc1.net/telegram/webhook
```

**Если видишь ошибку или предупреждение, скопируй его и сообщи мне!**

### ШАГ 3: Проверить webhook через браузер

Открой в браузере:
```
https://razmik-kutinava-telegram-quiz-d64a.twc1.net/telegram/check_webhook
```

Должно показать JSON с информацией о webhook:
```json
{
  "ok": true,
  "webhook_info": {
    "url": "https://razmik-kutinava-telegram-quiz-d64a.twc1.net/telegram/webhook",
    "pending_update_count": 0
  },
  "expected_url": "https://razmik-kutinava-telegram-quiz-d64a.twc1.net/telegram/webhook"
}
```

**Если `url` пустой или отличается от `expected_url`, значит webhook не установлен!**

### ШАГ 4: Проверить переменные окружения

Открой в браузере:
```
https://razmik-kutinava-telegram-quiz-d64a.twc1.net/telegram/check_env
```

Должно показать:
```json
{
  "token_set": true,
  "token_source": "TELEGRAM_BOT_TOKEN",
  "token_length": 46,
  "web_app_url": "https://razmik-kutinava-telegram-quiz-d64a.twc1.net"
}
```

**Если `token_set: false` или `web_app_url` пустой, значит переменные окружения не установлены!**

### ШАГ 5: Если webhook не установлен - установить вручную

Если в логах видишь ошибку или webhook не установлен, можно установить его вручную через браузер:

```
https://api.telegram.org/bot8761820883:AAFUdSvQxPhLbyn2fzpFbLc2VJIbis9fgho/setWebhook?url=https://razmik-kutinava-telegram-quiz-d64a.twc1.net/telegram/webhook
```

Должно вернуть:
```json
{
  "ok": true,
  "result": true,
  "description": "Webhook was set"
}
```

### ШАГ 6: Протестировать бота

1. Открой Telegram
2. Найди бота `@springbonus_bot`
3. Отправь команду `/start`
4. Должно появиться сообщение с текстом и кнопкой "Пройти квиз"

**После отправки `/start` в логах Timeweb Cloud ДОЛЖЕН появиться запрос:**
```
================================================================================
[REQUEST_LOGGER] POST /telegram/webhook
[CONTROLLER] POST /telegram/webhook
[DEBUG] Message received - chat_id: 219951825, text: "/start"
[DEBUG] Processing /start command for chat_id: 219951825
```

## Возможные проблемы и решения

### Проблема 1: В логах нет записей `[INIT]`

**Причина:** Initializer не выполняется или переменные окружения не установлены

**Решение:**
1. Проверь переменные окружения в Timeweb Cloud Dashboard
2. Убедись, что `TELEGRAM_BOT_TOKEN` и `TELEGRAM_WEB_APP_URL` установлены
3. Перезапусти приложение

### Проблема 2: Webhook не установлен (проверка через `/telegram/check_webhook`)

**Причина:** Telegram API не может установить webhook или URL недоступен

**Решение:**
1. Установи webhook вручную через браузер (ШАГ 5)
2. Проверь, что URL доступен извне (должен возвращать 200 OK)
3. Проверь, что используется HTTPS (Telegram требует HTTPS)

### Проблема 3: Webhook установлен, но запросы не приходят

**Причина:** Telegram не может достучаться до webhook URL

**Решение:**
1. Проверь, что URL доступен извне: `curl https://razmik-kutinava-telegram-quiz-d64a.twc1.net/telegram/webhook`
2. Проверь логи - возможно, запросы блокируются
3. Проверь, что порт 3000 открыт и доступен

## Что проверить в Timeweb Cloud Dashboard

1. **Переменные окружения:**
   - `TELEGRAM_BOT_TOKEN` = `8761820883:AAFUdSvQxPhLbyn2fzpFbLc2VJIbis9fgho`
   - `TELEGRAM_WEB_APP_URL` = `https://razmik-kutinava-telegram-quiz-d64a.twc1.net`

2. **Статус приложения:** должно быть "Running"

3. **Логи:** должны быть записи `[INIT]` при запуске

## Резюме

✅ Добавлено подробное логирование  
✅ Добавлен endpoint для проверки webhook  
⏳ Нужно перезапустить приложение  
⏳ Проверить логи после перезапуска  
⏳ Проверить webhook через `/telegram/check_webhook`  
⏳ Если webhook не установлен - установить вручную
