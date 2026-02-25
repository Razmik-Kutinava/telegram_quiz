# Настройка приложения на Render

## ✅ Текущий URL приложения
**https://telegram-quiz-sirr.onrender.com**

## Что уже сделано:
- ✅ Webhook настроен на: `https://telegram-quiz-sirr.onrender.com/telegram/webhook`
- ✅ Production конфигурация настроена для `.onrender.com` доменов

## Что нужно сделать в Render Dashboard:

### 1. Установить переменные окружения

Зайдите в Render Dashboard → ваш сервис → Settings → Environment Variables

Добавьте/обновите:
- `TELEGRAM_WEB_APP_URL` = `https://telegram-quiz-sirr.onrender.com`
- `TELEGRAM_BOT_TOKEN` = `8761820883:AAFUdSvQxPhLbyn2fzpFbLc2VJIbis9fgho`
- `RAILS_MASTER_KEY` = (значение из `config/master.key`)

После добавления переменных **перезапустите сервис**.

### 2. Обновить Mini App в BotFather

1. Откройте [@BotFather](https://t.me/BotFather) в Telegram
2. Отправьте `/myapps`
3. Выберите вашего бота
4. Отправьте `/editapp`
5. Укажите URL: `https://telegram-quiz-sirr.onrender.com`
6. Сохраните

## Проверка работы:

1. **Health check:** https://telegram-quiz-sirr.onrender.com/up
2. **Главная страница:** https://telegram-quiz-sirr.onrender.com
3. **Отправьте `/start` боту** - должна появиться кнопка "Открыть квиз"
4. **Нажмите на кнопку** - должно открыться Mini App

## Если что-то не работает:

1. Проверьте логи в Render Dashboard
2. Убедитесь что все переменные окружения установлены
3. Убедитесь что сервис перезапущен после изменения переменных
4. Проверьте что webhook установлен: 
   ```bash
   curl https://api.telegram.org/bot8761820883:AAFUdSvQxPhLbyn2fzpFbLc2VJIbis9fgho/getWebhookInfo
   ```
