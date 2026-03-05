# PowerShell скрипт для установки Telegram webhook

$token = $env:TELEGRAM_BOT_TOKEN
if (-not $token) {
    $token = $env:TELEGRAM_TOKEN
}

$webhookUrl = $env:TELEGRAM_WEBHOOK_URL
if (-not $webhookUrl) {
    $webhookUrl = $env:TELEGRAM_WEB_APP_URL
}
if (-not $webhookUrl) {
    $webhookUrl = "https://razmik-kutinava-telegram-quiz-d64a.twc1.net"
}

if (-not $webhookUrl.EndsWith("/telegram/webhook")) {
    $webhookUrl = $webhookUrl.TrimEnd('/') + "/telegram/webhook"
}

Write-Host "=" * 80
Write-Host "Telegram Webhook Setup"
Write-Host "=" * 80
Write-Host "Token: $($token.Substring(0, [Math]::Min(10, $token.Length)))..."
Write-Host "Webhook URL: $webhookUrl"
Write-Host "=" * 80

if (-not $token) {
    Write-Host "ERROR: TELEGRAM_BOT_TOKEN or TELEGRAM_TOKEN not set!" -ForegroundColor Red
    exit 1
}

# Проверяем текущий webhook
Write-Host "`n1. Checking current webhook..."
$getWebhookUri = "https://api.telegram.org/bot$token/getWebhookInfo"
$response = Invoke-RestMethod -Uri $getWebhookUri -Method Get

if ($response.ok) {
    Write-Host "Current webhook URL: $($response.result.url)"
    Write-Host "Pending updates: $($response.result.pending_update_count)"
    
    if ($response.result.url -ne $webhookUrl) {
        Write-Host "`n⚠️  Webhook URL mismatch!" -ForegroundColor Yellow
        Write-Host "   Current: $($response.result.url)"
        Write-Host "   Expected: $webhookUrl"
        
        Write-Host "`n2. Setting webhook to correct URL..."
        $setWebhookUri = "https://api.telegram.org/bot$token/setWebhook?url=$([System.Web.HttpUtility]::UrlEncode($webhookUrl))"
        $setResponse = Invoke-RestMethod -Uri $setWebhookUri -Method Get
        
        if ($setResponse.ok) {
            Write-Host "✅ Webhook successfully set!" -ForegroundColor Green
            Write-Host "   URL: $webhookUrl"
        } else {
            Write-Host "❌ Failed to set webhook: $($setResponse.description)" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "`n✅ Webhook URL is correct!" -ForegroundColor Green
    }
} else {
    Write-Host "❌ Failed to get webhook info: $($response.description)" -ForegroundColor Red
    exit 1
}

Write-Host "`n" + ("=" * 80)
Write-Host "Done!"
Write-Host "=" * 80
