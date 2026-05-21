#!/bin/sh
set -eu

DEPLOY_PATH="${1:?DEPLOY_PATH manquant}"
RELEASE_PATH="${2:?RELEASE_PATH manquant}"
KEEP_RELEASES="${3:-5}"
PHP_BINARY="${4:-php}"
COMPOSER_BINARY="${5:-composer}"
RUN_MIGRATIONS="${6:-true}"
RUN_QUEUE_RESTART="${7:-true}"

CURRENT_LINK="${DEPLOY_PATH%/}/current"
RELEASES_DIR="${DEPLOY_PATH%/}/releases"
SHARED_DIR="${DEPLOY_PATH%/}/shared"

log() {
    printf '\n==> %s\n' "$*"
}

fail() {
    printf >&2 'deploy remote: %s\n' "$*"
    exit 1
}

need_command() {
    command -v "$1" >/dev/null 2>&1 || fail "commande introuvable sur le VPS: $1"
}

[ -d "$RELEASE_PATH" ] || fail "release introuvable: $RELEASE_PATH"
[ -f "$SHARED_DIR/.env" ] || fail "cree d'abord le fichier $SHARED_DIR/.env sur le VPS"

case "$KEEP_RELEASES" in
    ''|*[!0-9]*) fail "KEEP_RELEASES doit etre numerique" ;;
esac

need_command "$PHP_BINARY"
need_command "$COMPOSER_BINARY"

log "Preparation des dossiers partages"
mkdir -p \
    "$SHARED_DIR/storage/app/public" \
    "$SHARED_DIR/storage/framework/cache/data" \
    "$SHARED_DIR/storage/framework/sessions" \
    "$SHARED_DIR/storage/framework/testing" \
    "$SHARED_DIR/storage/framework/views" \
    "$SHARED_DIR/storage/logs"

rm -rf "$RELEASE_PATH/storage"
mkdir -p "$RELEASE_PATH/bootstrap/cache"
ln -s "$SHARED_DIR/storage" "$RELEASE_PATH/storage"
ln -sfn "$SHARED_DIR/.env" "$RELEASE_PATH/.env"

cd "$RELEASE_PATH"

log "Installation Composer"
"$COMPOSER_BINARY" install \
    --no-dev \
    --prefer-dist \
    --no-interaction \
    --no-progress \
    --optimize-autoloader

if [ -f python/requirements.txt ]; then
    need_command python3

    log "Installation de l'environnement Python audio"
    python3 -m venv "$SHARED_DIR/python-venv"
    "$SHARED_DIR/python-venv/bin/pip" install --upgrade pip
    "$SHARED_DIR/python-venv/bin/pip" install -r python/requirements.txt

    rm -rf python/venv
    ln -s "$SHARED_DIR/python-venv" python/venv
fi

log "Optimisation Laravel"
"$PHP_BINARY" artisan optimize:clear

if [ "$RUN_MIGRATIONS" = "true" ]; then
    "$PHP_BINARY" artisan migrate --force
fi

"$PHP_BINARY" artisan storage:link --force
"$PHP_BINARY" artisan config:cache
"$PHP_BINARY" artisan route:cache
"$PHP_BINARY" artisan view:cache
"$PHP_BINARY" artisan event:cache

log "Activation de la nouvelle release"
ln -sfn "$RELEASE_PATH" "${CURRENT_LINK}.next"
if mv -Tf "${CURRENT_LINK}.next" "$CURRENT_LINK" 2>/dev/null; then
    :
else
    rm -f "$CURRENT_LINK"
    ln -s "$RELEASE_PATH" "$CURRENT_LINK"
fi

cd "$CURRENT_LINK"

if [ "$RUN_QUEUE_RESTART" = "true" ]; then
    log "Redemarrage logique des queues Laravel"
    "$PHP_BINARY" artisan queue:restart || true
fi

log "Nettoyage des anciennes releases"
release_count=0
for release in $(ls -dt "$RELEASES_DIR"/* 2>/dev/null || true); do
    release_count=$((release_count + 1))
    if [ "$release_count" -gt "$KEEP_RELEASES" ]; then
        rm -rf "$release"
    fi
done

log "Deploy termine"
