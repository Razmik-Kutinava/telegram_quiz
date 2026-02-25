# Скрипт для настройки Telegram Webhook (PowerShell)
# Использование: .\setup_webhook.ps1 YOUR_APP_URL

param(
    [Parameter(Mandatory=$true)]
    [string]$AppUrl
)

$BOT_TOKEN = "8761820883:AAFUdSvQxPhLbyn2fzpFbLc2VJIbis9fgho"
$WEBHOOK_URL = "$AppUrl/telegram/webhook"

Write-Host "Настраиваю webhook для бота..." -ForegroundColor Cyan
Write-Host "URL приложения: $AppUrl" -ForegroundColor Yellow
Write-Host "Webhook URL: $WEBHOOK_URL" -ForegroundColor Yellow
Write-Host ""

try {
    $boundary = [System.Guid]::NewGuid().ToString()
    $bodyLines = @(
        "--$boundary",
        "Content-Disposition: form-data; name=`"url`"",
        "",
        $WEBHOOK_URL,
        "--$boundary--"
    )
    $body = $bodyLines -join "`r`n"
    
    $response = Invoke-RestMethod -Uri "https://api.telegram.org/bot${BOT_TOKEN}/setWebhook" -Method Post -ContentType "multipart/form-data; boundary=$boundary" -Body $body
    
    Write-Host "Ответ от Telegram API:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 10
    
    if ($response.ok -eq $true) {
        Write-Host ""
        Write-Host "✅ Webhook успешно настроен!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Теперь обновите Mini App URL в BotFather:" -ForegroundColor Yellow
        Write-Host "1. Откройте @BotFather в Telegram"
        Write-Host "2. Отправьте /myapps"
        Write-Host "3. Выберите вашего бота"
        Write-Host "4. Отправьте /editapp"
        Write-Host "5. Укажите URL: $AppUrl" -ForegroundColor Cyan
    } else {
        Write-Host ""
        Write-Host "❌ Ошибка при настройке webhook" -ForegroundColor Red
        Write-Host "Описание: $($response.description)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host ""
    Write-Host "❌ Ошибка при выполнении запроса:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
