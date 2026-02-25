#!/bin/bash
cd /mnt/c/Tools/workarea/telegram_quiz
echo "Применяю миграции..."
bin/rails db:migrate
echo "Заполняю начальные данные..."
bin/rails db:seed
echo "Готово! Миграции применены."
