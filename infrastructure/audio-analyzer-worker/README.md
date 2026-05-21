# VPS Worker — Audio Analyzer (Multi-Instance)

Ce dossier déploie le service Python `audio-analyzer` en **3 instances** derrière un load balancer **Nginx** sur un VPS dédié.

Cette configuration est **répétable** : tu peux la déployer sur 2 (ou plus) VPS
workers identiques. Le Cloudflare Worker se charge alors de répartir la charge
globalement entre les VPS (random + failover).

## Architecture

```
Cloudflare Worker (orchestrateur)
    ↓  POST /analyze
    ↓  https://analyzer.arborisis.com (ou IP du VPS worker)
Nginx (load balancer — least_conn)
    ↓
┌──────────┬──────────┬──────────┐
analyzer-1 analyzer-2 analyzer-3
└──────────┴──────────┴──────────┘
```

Chaque instance est isolée (volume temporaire dédié, limite CPU/mémoire).

## Prérequis sur le VPS Worker

- Docker + Docker Compose
- Git (pour pull le repo)
- Aucune stack web (pas de PHP, Nginx, PostgreSQL, Redis)
- Ports ouverts : 80 (Nginx), 22 (SSH)

## Setup

### 1. Cloner le repo

```bash
git clone <repo> /var/www/arborisis
cd /var/www/arborisis/infrastructure/audio-analyzer-worker
```

### 2. Créer le fichier d'environnement

```bash
cp ../../services/audio-analyzer/.env.example .env
nano .env
```

Variables obligatoires :

```env
ANALYZER_SECRET=<même-token-que-laravel-et-worker>
LARAVEL_API_URL=https://arborisis.com
LARAVEL_API_SECRET=<token-callback-laravel>
R2_ENDPOINT=https://<account-id>.r2.cloudflarestorage.com
R2_ACCESS_KEY_ID=...
R2_SECRET_ACCESS_KEY=...
R2_BUCKET=arborisis
```

### 3. Build et démarrage

```bash
docker compose up -d --build
```

### 4. Vérification

```bash
# Healthcheck global (via Nginx)
curl http://localhost/health

# Healthcheck instance directe
curl http://localhost:8000/health  # ne fonctionnera pas, Nginx expose seul le port 80

# Logs
docker compose logs -f analyzer-1
docker compose logs -f nginx
```

### 5. Firewall

Bloquer tout accès direct aux instances. Seul Nginx (port 80) doit être accessible.

```bash
sudo ufw default deny incoming
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw enable
```

### 6. Configurer le Cloudflare Worker

#### Un seul VPS worker

```bash
wrangler secret put ANALYZER_URL
# https://worker1.arborisis.com
```

#### Deux VPS workers (ou plus)

```bash
wrangler secret put ANALYZER_URLS
# https://worker1.arborisis.com,https://worker2.arborisis.com
```

Le Worker distribue aléatoirement entre les URLs et bascule automatiquement
sur un autre VPS en cas d'erreur réseau ou 5xx.

## Scaler (ajouter une instance)

1. **Copier** le bloc `analyzer-3` dans `docker-compose.yml` en `analyzer-4`.
2. **Ajouter** le volume `analyzer-tmp-4:` dans la section `volumes:`.
3. **Ajouter** `analyzer-4:8000` dans `nginx/nginx.conf`.
4. **Redémarrer** :

```bash
docker compose up -d --build
```

> 💡 Si tu anticipes beaucoup de scaling, envisage Traefik ou Docker Swarm pour l'auto-discovery. Cette config explicite reste préférable pour 3–6 instances.

## Monitoring

```bash
# CPU par conteneur
docker stats

# Nombre d'analyses en cours (approximatif via connexions Nginx)
docker compose exec nginx cat /var/log/nginx/access.log | grep /analyze
```

## Déploiement rapide

Un script `deploy.sh` est fourni pour automatiser le pull + rebuild :

```bash
./deploy.sh
```

Ou manuellement :

```bash
cd /var/www/arborisis
 git pull origin main
 cd infrastructure/audio-analyzer-worker
 docker compose down
 docker compose up -d --build
```

## Sécurité

- Le Bearer token `ANALYZER_SECRET` est le seul point d'authentification.
- Aucune base de données sur ce VPS.
- Les fichiers temporaires sont dans des volumes Docker isolés par instance.
- Le callback vers Laravel utilise un token séparé (`LARAVEL_API_SECRET`).
