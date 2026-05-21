#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

HOSTS_FILE="${HOSTS_FILE:-hosts.prod}"
REMOTE_DIR="${REMOTE_DIR:-/var/www/arborisis}"
ENV_FILE="${ENV_FILE:-.env}"

if [ ! -f "$HOSTS_FILE" ]; then
    echo "Missing $HOSTS_FILE. Copy hosts.example to hosts.prod and set SSH targets." >&2
    exit 1
fi

load_host() {
    awk -F= -v key="$1" '$1 == key { print $2 }' "$HOSTS_FILE"
}

WEB_HOST="$(load_host web)"
DATA_HOST="$(load_host data)"
WORKERS_HOST="$(load_host workers)"

sync_repo() {
    host="$1"
    echo "[sync] $host"
    ssh "$host" "mkdir -p '$REMOTE_DIR'"
    rsync -az --delete \
        --exclude '.git' \
        --exclude 'arborisis/.env' \
        --exclude 'arborisis/discord-bot/.env' \
        --exclude 'services/audio-analyzer/.env' \
        --exclude 'infrastructure/docker/.env' \
        --exclude 'infrastructure/radio/.env' \
        --exclude 'node_modules' \
        --exclude 'vendor' \
        ../../ "$host:$REMOTE_DIR/"
}

run_role() {
    host="$1"
    role="$2"
    echo "[deploy] $role on $host"
    ssh "$host" "cd '$REMOTE_DIR/infrastructure/docker' && ENV_FILE='$ENV_FILE' ./deploy-local.sh '$role'"
}

case "${1:-all}" in
    sync)
        sync_repo "$DATA_HOST"
        sync_repo "$WEB_HOST"
        sync_repo "$WORKERS_HOST"
        ;;

    data)
        sync_repo "$DATA_HOST"
        run_role "$DATA_HOST" data
        ;;

    web)
        sync_repo "$WEB_HOST"
        run_role "$WEB_HOST" web
        ;;

    workers)
        sync_repo "$WORKERS_HOST"
        run_role "$WORKERS_HOST" workers
        ;;

    migrate)
        run_role "$DATA_HOST" backup
        run_role "$WEB_HOST" migrate
        ;;

    all)
        sync_repo "$DATA_HOST"
        sync_repo "$WEB_HOST"
        sync_repo "$WORKERS_HOST"
        run_role "$DATA_HOST" data
        run_role "$WEB_HOST" web
        run_role "$WORKERS_HOST" workers
        run_role "$DATA_HOST" backup
        run_role "$WEB_HOST" migrate
        ;;

    *)
        echo "Usage: $0 {sync|data|web|workers|migrate|all}" >&2
        exit 1
        ;;
esac
