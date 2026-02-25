# Render Deployment Fix

## What was fixed:

1. **Changed render.yaml to use Docker** instead of Ruby native build
   - Removed `env: ruby`, added `runtime: docker`
   - This fixes port 10000 issue (Thruster bypass)

2. **Fixed database migrations** in docker-entrypoint
   - Now runs `db:prepare` on every startup
   - Fixes /up health check failures

3. **Removed hardcoded PORT=3000**
   - Render provides PORT env var automatically
   - Dockerfile now uses `${PORT:-3000}`

## Deploy steps:

1. **Commit and push changes:**
```bash
git add render.yaml bin/docker-entrypoint
git commit -m "Fix Render deployment: use Docker, auto-run migrations"
git push origin main
```

2. **Redeploy on Render:**
   - Go to https://dashboard.render.com
   - Your service will auto-deploy, OR click "Manual Deploy" → "Deploy latest commit"

3. **After deployment succeeds, set Telegram webhook:**
```bash
curl "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/setWebhook?url=https://telegram-quiz-sirr.onrender.com/telegram/webhook"
```

## Expected results:
- ✅ App listens on correct PORT (Render's dynamic port)
- ✅ `/up` returns `{"status":"ok"}`
- ✅ Telegram webhook receives updates (no 502)
- ✅ Database migrations run automatically

## Troubleshooting:

If still fails, check Render logs:
```bash
# Check if PORT is set correctly
echo "PORT should be 10000 (Render's default)"

# Check if DB is created
rails db:migrate:status
```
