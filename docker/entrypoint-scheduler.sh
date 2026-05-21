#!/usr/bin/env sh
set -eu

# =============================================================================
# Arborisis — Entrypoint Scheduler (Cron)
# =============================================================================

echo "[entrypoint-scheduler] Starting Laravel Scheduler..."

mkdir -p \
    storage/framework/cache \
    storage/framework/views \
    storage/logs \
    bootstrap/cache

chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Attendre que l'app soit prête
sleep 5

# Exécuter schedule:run toutes les 60 secondes
while true; do
    php artisan schedule:run --ansi --no-interaction >> /var/log/scheduler.log 2>&1 || true
    sleep 60
done
