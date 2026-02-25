# Инструкция по деплою на Render

## Шаги для деплоя:

### 1. Подготовка переменных окружения

В Render Dashboard добавьте следующие переменные окружения:

- `RAILS_MASTER_KEY` - скопируйте значение из `config/master.key`
- `TELEGRAM_BOT_TOKEN` - `8761820883:AAFUdSvQxPhLbyn2fzpFbLc2VJIbis9fgho`
- `TELEGRAM_WEB_APP_URL` - будет установлен автоматически после деплоя (например: `https://telegram-quiz.onrender.com`)

### 2. Деплой через Render Dashboard

1. Зайдите на [render.com](https://render.com)
2. Нажмите "New +" → "Web Service"
3. Подключите ваш Git репозиторий
4. Render автоматически обнаружит `render.yaml` и использует его настройки
5. Или вручную:
   - **Name**: `telegram-quiz`
   - **Environment**: `Ruby`
   - **Region**: `Frankfurt` (или ближайший к вам)
   - **Branch**: `main` (или ваша основная ветка)
   - **Root Directory**: оставьте пустым
   - **Build Command**: `bundle install && bundle exec rails assets:precompile`
   - **Start Command**: `bundle exec rails db:migrate && bundle exec rails db:seed && bundle exec rails server -p $PORT -e production`

### 3. После деплоя

1. **Получите URL приложения** (например: `https://telegram-quiz.onrender.com`)

2. **Обновите переменную окружения `TELEGRAM_WEB_APP_URL`** в Render:
   - Зайдите в Settings → Environment
   - Обновите `TELEGRAM_WEB_APP_URL` на ваш URL
   - Перезапустите сервис

3. **Обновите Telegram Webhook**:
   ```bash
   curl -F "url=https://YOUR-APP-URL.onrender.com/telegram/webhook" \
     https://api.telegram.org/bot8761820883:AAFUdSvQxPhLbyn2fzpFbLc2VJIbis9fgho/setWebhook
   ```

4. **Обновите Mini App URL в BotFather**:
   - Откройте [@BotFather](https://t.me/BotFather)
   - `/myapps`
   - Выберите вашего бота
   - `/editapp`
   - Обновите URL на: `https://YOUR-APP-URL.onrender.com`

5. **Обновите production.rb** (опционально, для кастомного домена):
   ```ruby
   config.hosts << "your-custom-domain.com"
   ```

### 4. Проверка

- Health check: `https://YOUR-APP-URL.onrender.com/up`
- Главная страница: `https://YOUR-APP-URL.onrender.com`
- API endpoint: `https://YOUR-APP-URL.onrender.com/api/quiz_sessions`

## Примечания

- Render автоматически предоставляет HTTPS
- База данных SQLite будет храниться в persistent storage
- При каждом деплое миграции и seeds выполняются автоматически
- Логи доступны в Render Dashboard
