#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"

deploy_worker() {
    dir="$1"
    echo "[cloudflare] Deploy $dir"
    cd "$ROOT_DIR/$dir"
    npm ci
    wrangler deploy
}

deploy_worker workers/r2-proxy
deploy_worker workers/audio-analysis-orchestrator
deploy_worker workers/arborisis-ai-agent

if [ "${DEPLOY_AUDIO_ANALYZER_CONTAINER:-false}" = "true" ]; then
    deploy_worker workers/audio-analyzer-container
fi
