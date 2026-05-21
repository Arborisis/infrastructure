#!/usr/bin/env sh
set -eu

# =============================================================================
# Arborisis — Entrypoint Queue Worker
# =============================================================================

echo "[entrypoint-queue] Starting Laravel Queue Worker..."

mkdir -p \
    storage/framework/cache \
    storage/framework/views \
    storage/logs \
    bootstrap/cache

chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Attendre que l'app soit prête
sleep 5

# Démarrer le worker avec retry
exec php artisan queue:work \
    --queue="${QUEUE_QUEUE:-default}" \
    --sleep=3 \
    --tries=3 \
    --max-time=3600 \
    --ansi
