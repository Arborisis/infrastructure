#!/usr/bin/env sh
set -eu

# =============================================================================
# Arborisis — Entrypoint Development
# =============================================================================

echo "[entrypoint-dev] Starting Arborisis development container..."

mkdir -p \
    storage/app \
    storage/framework/cache \
    storage/framework/sessions \
    storage/framework/testing \
    storage/framework/views \
    storage/logs \
    bootstrap/cache \
    public

chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Storage link
if [ ! -L public/storage ]; then
    php artisan storage:link >/dev/null 2>&1 || true
fi

# Migrations automatiques en dev
if [ -n "${APP_KEY:-}" ]; then
    php artisan migrate --force --ansi || true
fi

echo "[entrypoint-dev] Ready. Executing: $@"
exec "$@"
