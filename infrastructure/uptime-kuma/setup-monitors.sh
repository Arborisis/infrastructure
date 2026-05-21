#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Setup Uptime Kuma monitors for Arborisis
# =============================================================================
# Usage:
#   export UK_HOST=http://127.0.0.1:3001
#   export UK_USERNAME=admin
#   export UK_PASSWORD=your_password
#   export DISCORD_INTERNAL_API_TOKEN=your_token
#   bash setup-monitors.sh
# =============================================================================

UK_HOST="${UK_HOST:-http://127.0.0.1:3001}"
UK_USERNAME="${UK_USERNAME:-admin}"
UK_PASSWORD="${UK_PASSWORD:-}"
DISCORD_TOKEN="${DISCORD_INTERNAL_API_TOKEN:-}"

if [[ -z "$UK_PASSWORD" ]]; then
    echo "❌ Erreur : définissez UK_PASSWORD"
    exit 1
fi

if [[ -z "$DISCORD_TOKEN" ]]; then
    echo "⚠️  Warning : DISCORD_INTERNAL_API_TOKEN non défini — le monitor Discord sera créé sans auth header (à corriger après)."
fi

echo "🔐 Connexion à Uptime Kuma ($UK_HOST) ..."

# 1. Login
LOGIN_RESP=$(curl -s -X POST "$UK_HOST/api/login" \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"$UK_USERNAME\",\"password\":\"$UK_PASSWORD\"}")

TOKEN=$(echo "$LOGIN_RESP" | python3 -c "import sys,json; print(json.load(sys.stdin).get('token',''))" 2>/dev/null || true)

if [[ -z "$TOKEN" ]]; then
    echo "❌ Échec de connexion. Réponse : $LOGIN_RESP"
    exit 1
fi

echo "✅ Connecté. Import des monitors ..."

# 2. Création des monitors via l'API (v1 compatible)
# Note : Uptime Kuma n'expose pas d'API REST documentée publiquement stable.
# Ce script utilise les endpoints internes du frontend.
# Alternative : utiliser l'UI pour importer depuis backup JSON.

create_monitor() {
    local name="$1"
    local url="$2"
    local interval="${3:-60}"
    local timeout="${4:-10}"
    local max_retries="${5:-3}"
    local method="${6:-GET}"
    local headers="${7:-{}}"

    local payload
    payload=$(jq -n \
        --arg name "$name" \
        --arg url "$url" \
        --argjson interval "$interval" \
        --argjson timeout "$timeout" \
        --argjson maxretries "$max_retries" \
        --arg method "$method" \
        --argjson headers "$headers" \
        '{
            type: "http",
            name: $name,
            url: $url,
            method: $method,
            interval: $interval,
            timeout: $timeout,
            maxretries: $maxretries,
            retryInterval: 30,
            resendInterval: 0,
            expiryNotification: true,
            ignoreTls: false,
            upsideDown: false,
            packetSize: 56,
            accepted_statuscodes: ["200-299"],
            headers: $headers
        }'
    )

    curl -s -X POST "$UK_HOST/api/monitor" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN" \
        -d "$payload" > /dev/null

    echo "  ✓ $name"
}

# ---------------------------------------------------------------------------
# Monitors Arborisis
# ---------------------------------------------------------------------------

create_monitor "Laravel Health Check" "https://arborisis.com/api/health" 60 10 3 "GET"
create_monitor "Landing Page" "https://arborisis.com/" 120 15 3
create_monitor "Sounds Page" "https://arborisis.com/sounds" 120 15 3
create_monitor "Map Page" "https://arborisis.com/map" 120 15 3
create_monitor "API — Map Sounds" "https://arborisis.com/api/map/sounds" 60 10 3
create_monitor "API — Map Search" "https://arborisis.com/api/map/sounds/search" 120 10 3
create_monitor "Radio Page" "https://arborisis.com/radio" 120 15 3
create_monitor "API — Radio Now Playing" "https://arborisis.com/api/radio/now-playing" 60 10 3
create_monitor "Creators Page" "https://arborisis.com/creators" 120 15 3
create_monitor "API — Scientific Stats (Global)" "https://arborisis.com/api/scientific-stats/global" 120 10 3
create_monitor "API — Arborisis Points" "https://arborisis.com/api/arborisis-points" 120 10 3
create_monitor "API — Quests" "https://arborisis.com/api/quests" 120 10 3
create_monitor "API — Achievements" "https://arborisis.com/api/achievements" 120 10 3
create_monitor "API — Medals" "https://arborisis.com/api/medals" 120 10 3
create_monitor "API — Map Presence" "https://arborisis.com/api/map/presence" 120 10 3
create_monitor "Transparency Page" "https://arborisis.com/transparency" 300 15 3
create_monitor "Auth — Login Page" "https://arborisis.com/login" 300 15 3
create_monitor "Contact Page" "https://arborisis.com/contact" 300 15 3
create_monitor "Mission Page" "https://arborisis.com/mission" 300 15 3
create_monitor "ECHO Info Page" "https://arborisis.com/echo" 300 15 3
create_monitor "API — VAPID Public Key" "https://arborisis.com/api/vapid-public-key" 300 10 3

if [[ -n "$DISCORD_TOKEN" ]]; then
    create_monitor "Discord Bot Internal API" "https://arborisis.com/api/internal/discord/stats" 60 10 3 "GET" \
        "{\"X-Internal-Token\": \"$DISCORD_TOKEN\"}"
else
    create_monitor "Discord Bot Internal API" "https://arborisis.com/api/internal/discord/stats" 60 10 3
fi

echo ""
echo "🎉 Tous les monitors sont créés. Accédez à $UK_HOST pour vérifier."
