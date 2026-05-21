#!/usr/bin/env sh
set -eu

# =============================================================================
# Arborisis — Entrypoint Production (PHP-FPM)
# =============================================================================

echo "[entrypoint] Starting Arborisis production container..."

# Création des répertoires de stockage
mkdir -p \
    storage/app \
    storage/framework/cache \
    storage/framework/sessions \
    storage/framework/testing \
    storage/framework/views \
    storage/logs \
    bootstrap/cache \
    public

# Restauration des assets si public/build manque (premier démarrage)
if [ ! -d public/build ] && [ -d public.dist ]; then
    echo "[entrypoint] Restoring public assets from public.dist..."
    cp -a public.dist/. public/
fi

# Permissions
chown -R www-data:www-data storage bootstrap/cache public
chmod -R 775 storage bootstrap/cache

# Optimisations Laravel (si APP_KEY est présent)
if [ "${CONTAINER_SKIP_OPTIMIZE:-false}" != "true" ] && [ -n "${APP_KEY:-}" ]; then
    echo "[entrypoint] Running Laravel optimizations..."
    php artisan optimize:clear >/dev/null 2>&1 || true
    php artisan package:discover --ansi >/dev/null 2>&1 || true
    php artisan optimize >/dev/null 2>&1 || true
fi

# Storage link
if [ "${CONTAINER_STORAGE_LINK:-true}" = "true" ] && [ ! -L public/storage ]; then
    echo "[entrypoint] Creating storage link..."
    php artisan storage:link >/dev/null 2>&1 || true
fi

# Migrations (optionnel — désactivé par défaut en prod pour éviter les locks)
if [ "${CONTAINER_RUN_MIGRATIONS:-false}" = "true" ] && [ -n "${APP_KEY:-}" ]; then
    echo "[entrypoint] Running database migrations..."
    php artisan migrate --force --ansi || true
fi

echo "[entrypoint] Ready. Executing: $@"
exec "$@"
