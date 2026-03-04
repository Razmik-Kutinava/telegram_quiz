# Настройка приложения на Timeweb Cloud

## ✅ Что уже сделано в коде:
- ✅ Поддержка Timeweb доменов в `production.rb`
- ✅ Разрешение внутренних запросов от балансировщика (Docker сеть)
- ✅ Автоматическая настройка webhook при запуске

## 🔧 Что нужно сделать в Timeweb Cloud Dashboard:

### 1. Установить переменные окружения

Зайдите в Timeweb Cloud Dashboard → ваш проект → **Settings** → **Environment Variables**

**ОБЯЗАТЕЛЬНО добавьте:**

| Переменная | Значение | Описание |
|------------|----------|----------|
| `RAILS_ENV` | `production` | Окружение Rails |
| `RAILS_MASTER_KEY` | `[скопируй из config/master.key]` | Ключ для credentials |
| `SECRET_KEY_BASE` | `99ffd25fc294c94681c6ad658bb163af2c85d667f7e378fe62ce21b8d849e1a6fb184f3913ccbec41e75cb094b3671825c1270b85769eeb16b6feca78f2cb226` | Секретный ключ |
| `TELEGRAM_BOT_TOKEN` | `8761820883:AAFUdSvQxPhLbyn2fzpFbLc2VJIbis9fgho` | Токен бота |
| `TELEGRAM_TOKEN` | `8761820883:AAFUdSvQxPhLbyn2fzpFbLc2VJIbis9fgho` | Дубликат токена |
| `TELEGRAM_WEB_APP_URL` | `https://[ваш-url-timeweb]` | **ВАЖНО!** URL вашего приложения от Timeweb |
| `RAILS_LOG_TO_STDOUT` | `true` | Логи в консоль |
| `RAILS_SERVE_STATIC_FILES` | `true` | Раздача статики |
| `PORT` | `3000` | Порт приложения |
| `ADMIN_PASSWORD` | `admin123` | Пароль админ-панели (измените!) |

**Опционально:**

| Переменная | Значение | Описание |
|------------|----------|----------|
| `TIMEWEB_URL` | `https://[ваш-url-timeweb]` | Альтернативное имя для URL (дублирует TELEGRAM_WEB_APP_URL) |
| `RAILS_LOG_LEVEL` | `info` | Уровень логирования |

### 2. Получить URL приложения

После деплоя в Timeweb Cloud Dashboard:
1. Найдите ваш проект
2. Скопируйте **URL приложения** (например: `https://telegram-quiz-xxx.timeweb.cloud`)
3. Обновите переменную `TELEGRAM_WEB_APP_URL` на этот URL
4. Если используете `TIMEWEB_URL`, обновите и её тоже

### 3. Перезапустить приложение

После добавления/изменения переменных окружения:
1. В Timeweb Cloud Dashboard нажмите **"Restart"** или **"Redeploy"**
2. Дождитесь завершения перезапуска

### 4. Проверить работу

1. **Health check:** `https://[ваш-url-timeweb]/up` - должен вернуть 200 OK
2. **Главная страница:** `https://[ваш-url-timeweb]/` - должна открыться
3. **Проверка webhook:** Отправьте `/start` боту в Telegram - должна появиться кнопка

## 🔍 Решение проблем

### Проблема: "Blocked hosts: 172.18.0.5:3000"

**Решение:** Уже исправлено в коде. Если всё ещё появляется:
- Убедитесь что переменная `TELEGRAM_WEB_APP_URL` установлена
- Перезапустите приложение после добавления переменных

### Проблема: "Webhook URL could not be determined"

**Решение:** 
- Убедитесь что переменная `TELEGRAM_WEB_APP_URL` установлена и содержит полный URL (с `https://`)
- Пример правильного значения: `https://telegram-quiz-xxx.timeweb.cloud`
- После установки переменной перезапустите приложение

### Проблема: Приложение не отвечает

**Решение:**
1. Проверьте логи в Timeweb Cloud Dashboard
2. Убедитесь что все обязательные переменные установлены
3. Проверьте что `PORT=3000` установлен
4. Проверьте health check: `/up`

## 📝 После успешного деплоя

1. Обновите Mini App URL в BotFather:
   - Откройте [@BotFather](https://t.me/BotFather)
   - `/myapps` → выберите бота → `/editapp`
   - Укажите URL: `https://[ваш-url-timeweb]`

2. Проверьте что webhook установлен автоматически (должно быть в логах):
   ```
   [INIT] Telegram webhook set response: 200 ...
   ```

3. Если webhook не установился автоматически, установите вручную:
   ```
   https://api.telegram.org/bot8761820883:AAFUdSvQxPhLbyn2fzpFbLc2VJIbis9fgho/setWebhook?url=https://[ваш-url-timeweb]/telegram/webhook
   ```
