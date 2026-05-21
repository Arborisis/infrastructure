#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

ROLE="${1:-}"
ENV_FILE="${ENV_FILE:-.env}"

if [ ! -f "$ENV_FILE" ]; then
    echo "Missing $ENV_FILE. Start from .env.example and keep secrets in the app env files." >&2
    exit 1
fi

compose() {
    docker compose --env-file "$ENV_FILE" "$@"
}

case "$ROLE" in
    data)
        compose --profile data up -d postgres redis
        compose ps postgres redis
        ;;

    web)
        compose build app
        compose --profile web up -d app ssr reverb nginx
        if grep -q '^CLOUDFLARE_TUNNEL_TOKEN=.' "$ENV_FILE"; then
            compose --profile tunnel up -d cloudflared
        fi
        compose ps app ssr reverb nginx
        ;;

    workers)
        compose build app discord-bot
        compose --profile workers up -d queue scheduler discord-bot
        compose ps queue scheduler discord-bot
        ;;

    backup)
        mkdir -p backups
        stamp="$(date -u +%Y%m%dT%H%M%SZ)"
        compose exec -T postgres pg_dump -U "${POSTGRES_USER:-arborisis}" -d "${POSTGRES_DB:-arborisis}" -Fc > "backups/arborisis-$stamp.dump"
        echo "Created backups/arborisis-$stamp.dump"
        ;;

    migrate)
        compose exec -T app php artisan migrate --force
        compose exec -T app php artisan storage:link || true
        compose exec -T app php artisan optimize
        compose exec -T app php artisan queue:restart
        ;;

    status)
        compose ps
        ;;

    *)
        echo "Usage: $0 {data|web|workers|backup|migrate|status}" >&2
        exit 1
        ;;
esac
