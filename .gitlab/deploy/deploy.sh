#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
APP_DIR="${APP_DIR:-arborisis}"
APP_PATH="$ROOT_DIR/$APP_DIR"
REMOTE_SCRIPT="$ROOT_DIR/.gitlab/deploy/remote-release.sh"

DEPLOY_PORT="${DEPLOY_PORT:-22}"
DEPLOY_KEEP_RELEASES="${DEPLOY_KEEP_RELEASES:-5}"
PHP_BINARY="${PHP_BINARY:-php}"
COMPOSER_BINARY="${COMPOSER_BINARY:-composer}"
RUN_MIGRATIONS="${RUN_MIGRATIONS:-true}"
RUN_QUEUE_RESTART="${RUN_QUEUE_RESTART:-true}"

fail() {
    printf >&2 'deploy: %s\n' "$*"
    exit 1
}

require_var() {
    eval "value=\${$1:-}"
    [ -n "$value" ] || fail "la variable $1 est requise"
}

assert_safe_remote_value() {
    name="$1"
    value="$2"

    case "$value" in
        *[[:space:]]*|*\'*|*\"*|*\\*|*\`*|*\$*|*\;*|*\&*|*\|*|*\<*|*\>*|*\(*|*\)*|*\{*|*\}*)
            fail "$name contient un caractere non supporte pour une commande SSH: $value"
            ;;
    esac
}

require_var DEPLOY_HOST
require_var DEPLOY_USER
require_var DEPLOY_PATH

[ -d "$APP_PATH" ] || fail "dossier application introuvable: $APP_PATH"
[ -f "$REMOTE_SCRIPT" ] || fail "script distant introuvable: $REMOTE_SCRIPT"

case "$DEPLOY_PORT" in
    ''|*[!0-9]*) fail "DEPLOY_PORT doit etre numerique" ;;
esac

case "$DEPLOY_KEEP_RELEASES" in
    ''|*[!0-9]*) fail "DEPLOY_KEEP_RELEASES doit etre numerique" ;;
esac

assert_safe_remote_value DEPLOY_HOST "$DEPLOY_HOST"
assert_safe_remote_value DEPLOY_USER "$DEPLOY_USER"
assert_safe_remote_value DEPLOY_PATH "$DEPLOY_PATH"
assert_safe_remote_value DEPLOY_PORT "$DEPLOY_PORT"
assert_safe_remote_value DEPLOY_KEEP_RELEASES "$DEPLOY_KEEP_RELEASES"
assert_safe_remote_value PHP_BINARY "$PHP_BINARY"
assert_safe_remote_value COMPOSER_BINARY "$COMPOSER_BINARY"
assert_safe_remote_value RUN_MIGRATIONS "$RUN_MIGRATIONS"
assert_safe_remote_value RUN_QUEUE_RESTART "$RUN_QUEUE_RESTART"

commit_ref="${CI_COMMIT_REF_SLUG:-local}"
commit_sha="${CI_COMMIT_SHORT_SHA:-$(date +%Y%m%d%H%M%S)}"
pipeline_id="${CI_PIPELINE_ID:-manual}"
release_id=$(printf '%s-%s-%s' "$commit_ref" "$commit_sha" "$pipeline_id" | tr -c 'A-Za-z0-9._-' '-')
release_path="${DEPLOY_PATH%/}/releases/$release_id"

ssh_target="$DEPLOY_USER@$DEPLOY_HOST"
ssh_base="ssh -p $DEPLOY_PORT -o StrictHostKeyChecking=yes"

printf 'Deploy Arborisis vers %s:%s\n' "$ssh_target" "$release_path"

$ssh_base "$ssh_target" "mkdir -p ${DEPLOY_PATH%/}/releases ${DEPLOY_PATH%/}/shared $release_path"

rsync -az --delete \
    --exclude='.env' \
    --exclude='.git/' \
    --exclude='node_modules/' \
    --exclude='vendor/' \
    --exclude='storage/' \
    --exclude='bootstrap/cache/' \
    --exclude='python/venv/' \
    --exclude='tests/' \
    -e "ssh -p $DEPLOY_PORT -o StrictHostKeyChecking=yes" \
    "$APP_PATH/" \
    "$ssh_target:$release_path/"

$ssh_base "$ssh_target" sh -s -- \
    "$DEPLOY_PATH" \
    "$release_path" \
    "$DEPLOY_KEEP_RELEASES" \
    "$PHP_BINARY" \
    "$COMPOSER_BINARY" \
    "$RUN_MIGRATIONS" \
    "$RUN_QUEUE_RESTART" \
    < "$REMOTE_SCRIPT"
