# Исправление проблемы с командой /start в Telegram боте

## Проблема
Когда пользователь отправляет `/start` в боте, ничего не происходит - не появляется текст с кнопкой "Пройти квиз".

## Что было исправлено

1. **Исправлена установка webhook** - теперь используется правильный POST запрос вместо GET
2. **Добавлены скрипты для проверки webhook** - можно проверить статус webhook вручную

## Что нужно сделать СЕЙЧАС

### ШАГ 1: Перезапустить приложение в Timeweb Cloud

1. Зайди в Timeweb Cloud Dashboard
2. Найди проект `telegram-quiz`
3. Нажми **"Restart"** или **"Redeploy"**
4. Дождись завершения перезапуска (2-5 минут)

### ШАГ 2: Проверить переменные окружения

Убедись, что в Timeweb Cloud установлены ВСЕ эти переменные:

| Переменная | Значение |
|------------|----------|
| `TELEGRAM_BOT_TOKEN` | `8761820883:AAFUdSvQxPhLbyn2fzpFbLc2VJIbis9fgho` |
| `TELEGRAM_WEB_APP_URL` | `https://razmik-kutinava-telegram-quiz-d64a.twc1.net` |

**ВАЖНО:** `TELEGRAM_WEB_APP_URL` должен быть БЕЗ `/telegram/webhook` в конце!

### ШАГ 3: Проверить логи после перезапуска

После перезапуска в логах должно появиться:

```
[INIT] ✅ Telegram webhook successfully set: https://razmik-kutinava-telegram-quiz-d64a.twc1.net/telegram/webhook
```

Если видишь ошибку, скопируй её и сообщи мне.

### ШАГ 4: Проверить webhook вручную (опционально)

Если хочешь проверить webhook вручную, можешь использовать PowerShell скрипт:

```powershell
# Установи переменные окружения
$env:TELEGRAM_BOT_TOKEN = "8761820883:AAFUdSvQxPhLbyn2fzpFbLc2VJIbis9fgho"
$env:TELEGRAM_WEB_APP_URL = "https://razmik-kutinava-telegram-quiz-d64a.twc1.net"

# Запусти скрипт
.\scripts\set_webhook.ps1
```

Или через браузер:
```
https://api.telegram.org/bot8761820883:AAFUdSvQxPhLbyn2fzpFbLc2VJIbis9fgho/getWebhookInfo
```

Должно показать:
```json
{
  "ok": true,
  "result": {
    "url": "https://razmik-kutinava-telegram-quiz-d64a.twc1.net/telegram/webhook",
    "pending_update_count": 0
  }
}
```

### ШАГ 5: Протестировать бота

1. Открой Telegram
2. Найди бота `@springbonus_bot`
3. Отправь команду `/start`
4. Должно появиться сообщение с текстом и кнопкой "Пройти квиз"

## Если всё ещё не работает

1. **Проверь логи в Timeweb Cloud** - там должны быть записи о получении webhook запросов от Telegram
2. **Проверь, что webhook установлен правильно** - используй скрипт `set_webhook.ps1`
3. **Проверь, что переменная `TELEGRAM_WEB_APP_URL` установлена правильно** - должна быть с `https://` и БЕЗ `/telegram/webhook`

## Что изменилось в коде

### `config/initializers/telegram_webhook.rb`
- Исправлен метод установки webhook: теперь используется POST запрос с JSON body вместо GET
- Добавлена проверка результата установки webhook
- Улучшено логирование

### Новые файлы
- `scripts/check_webhook.rb` - Ruby скрипт для проверки webhook
- `scripts/set_webhook.ps1` - PowerShell скрипт для установки webhook

## Резюме

✅ Код исправлен и запушен в репозиторий  
✅ Webhook теперь устанавливается правильно при запуске приложения  
⏳ Нужно перезапустить приложение в Timeweb Cloud  
⏳ После перезапуска команда `/start` должна заработать
