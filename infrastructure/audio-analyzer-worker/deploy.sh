#!/usr/bin/env bash
set -euo pipefail

# deploy.sh — Déploiement rapide du VPS Worker Audio Analyzer
# Usage : ./deploy.sh

cd "$(dirname "$0")"

echo "[deploy] Pull du repo..."
git pull origin main

echo "[deploy] Rebuild des conteneurs..."
docker compose down
docker compose up -d --build

echo "[deploy] Healthcheck global..."
sleep 5
curl -fs http://localhost/health && echo "[deploy] OK" || echo "[deploy] Healthcheck failed"

echo "[deploy] Statut des conteneurs :"
docker compose ps
