# PowerShell script to set Telegram webhook for Render deployment

$BOT_TOKEN = "8761820883:AAFUdSvQxPhLbyn2fzpFbLc2VJIbis9fgho"
$WEBHOOK_URL = "https://telegram-quiz-sirr.onrender.com/telegram/webhook"

Write-Host "Setting Telegram webhook..." -ForegroundColor Yellow
Write-Host "URL: $WEBHOOK_URL" -ForegroundColor Cyan

$response = Invoke-RestMethod -Uri "https://api.telegram.org/bot$BOT_TOKEN/setWebhook" -Method Post -Body @{
    url = $WEBHOOK_URL
} -ContentType "application/x-www-form-urlencoded"

if ($response.ok) {
    Write-Host "✅ Webhook установлен успешно!" -ForegroundColor Green
    Write-Host "Webhook URL: $($response.result.url)" -ForegroundColor Cyan
} else {
    Write-Host "❌ Ошибка при установке webhook: $($response.description)" -ForegroundColor Red
}

Write-Host "`nПроверка webhook..." -ForegroundColor Yellow
$info = Invoke-RestMethod -Uri "https://api.telegram.org/bot$BOT_TOKEN/getWebhookInfo"
Write-Host "Webhook URL: $($info.result.url)" -ForegroundColor Cyan
Write-Host "Pending updates: $($info.result.pending_update_count)" -ForegroundColor Cyan
