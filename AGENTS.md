# AGENTS.md

## Cursor Cloud specific instructions

### Overview

This is a **Ruby on Rails 8.1.2** Telegram Bot + Web App ("НАПИ:БАР" cocktail quiz). It uses **Ruby 3.4.8**, **SQLite3** (file-based, no external DB server), **Tailwind CSS v4**, and **importmap-rails** (no Node.js/npm required).

### Ruby path

Ruby 3.4.8 is installed at `/home/ubuntu/.rubies/ruby-3.4.8/bin` and added to `PATH` via `~/.bashrc`. If Ruby is not found, ensure this path is on `PATH`.

### Running the app

- **Dev server:** `bin/dev` (starts Puma on port 3000 + Tailwind CSS watcher via foreman). Alternatively `bin/rails server` for just the web server.
- **Database:** `bin/rails db:prepare` (auto-creates SQLite files in `storage/`). Run `bin/rails db:migrate` first if `db/schema.rb` doesn't exist yet.
- The `bin/*` scripts may need `chmod +x bin/*` after a fresh clone.

### Lint / Test / Security

- **Lint:** `bin/rubocop` (rubocop-rails-omakase style)
- **Unit tests:** `bin/rails test` (requires `bin/rails db:test:prepare` first)
- **System tests:** `bin/rails test:system` (requires a browser driver; Selenium + Chrome)
- **Security scan:** `bin/brakeman --no-pager`
- **Gem audit:** `bin/bundler-audit`
- **JS audit:** `bin/importmap audit`

### Gotchas

- Most cocktail image assets (in `app/assets/images/cocktails/`) are sourced from external URLs that return 404. Only `cocktail68.png` downloads successfully from the rake task `bin/rails images:download`. The remaining images need placeholder files (copy from `cocktail68.png`) for the app and tests to work.
- The Telegram webhook controller needs `TELEGRAM_BOT_TOKEN` env var to send messages, but the web quiz UI works without it.
- No custom database migrations exist; `db:prepare` creates the schema from the built-in Solid Queue/Cache/Cable schemas.
