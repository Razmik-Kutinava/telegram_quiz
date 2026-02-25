# Быстрое исправление проблемы с ngrok

## Проблема
Ngrok туннель сломался, приложение не работает в Telegram Mini App.

## Решение

### Вариант 1: Использовать Render (рекомендуется - постоянное решение)

Если приложение уже задеплоено на Render:

1. **Получите URL вашего приложения** из Render Dashboard (например: `https://telegram-quiz.onrender.com`)

2. **Обновите переменную окружения в Render:**
   - Зайдите в Render Dashboard → ваш сервис → Settings → Environment
   - Найдите `TELEGRAM_WEB_APP_URL`
   - Установите значение: `https://YOUR-APP-URL.onrender.com`
   - Сохраните и перезапустите сервис

3. **Настройте webhook:**
   ```bash
   ./setup_webhook.sh https://YOUR-APP-URL.onrender.com
   ```
   
   Или вручную:
   ```bash
   curl -F "url=https://YOUR-APP-URL.onrender.com/telegram/webhook" \
     https://api.telegram.org/bot8761820883:AAFUdSvQxPhLbyn2fzpFbLc2VJIbis9fgho/setWebhook
   ```

4. **Обновите Mini App в BotFather:**
   - Откройте [@BotFather](https://t.me/BotFather)
   - `/myapps` → выберите бота → `/editapp`
   - Укажите URL: `https://YOUR-APP-URL.onrender.com`

### Вариант 2: Запустить новый ngrok (временное решение для разработки)

1. **Запустите Rails сервер локально:**
   ```bash
   rails server
   ```

2. **В другом терминале запустите ngrok:**
   ```bash
   ngrok http 3000
   ```

3. **Скопируйте новый HTTPS URL** (например: `https://abc123.ngrok-free.app`)

4. **Установите переменную окружения локально:**
   ```bash
   export TELEGRAM_WEB_APP_URL=https://abc123.ngrok-free.app
   ```
   
   Или создайте/обновите `.env`:
   ```
   TELEGRAM_WEB_APP_URL=https://abc123.ngrok-free.app
   ```

5. **Настройте webhook:**
   ```bash
   curl -F "url=https://abc123.ngrok-free.app/telegram/webhook" \
     https://api.telegram.org/bot8761820883:AAFUdSvQxPhLbyn2fzpFbLc2VJIbis9fgho/setWebhook
   ```

6. **Обновите Mini App в BotFather** с новым ngrok URL

## Проверка

После настройки проверьте:
- Health check: `https://YOUR-URL/up`
- Главная страница: `https://YOUR-URL`
- Отправьте `/start` боту - должна появиться кнопка "Открыть квиз"

## Важно

⚠️ **Ngrok URL меняется при каждом перезапуске!** Для продакшена используйте Render или другой постоянный хостинг.
