# Docker Arborisis

Cette stack Docker fait tourner Arborisis en services séparés :

- `nginx` : frontal HTTP, assets statiques, proxy WebSocket Reverb.
- `app` : Laravel PHP-FPM.
- `ssr` : serveur SSR Inertia.
- `queue` : workers Laravel (`high,default,discord,low`).
- `scheduler` : planificateur Laravel.
- `reverb` : WebSocket Laravel Reverb.
- `discord-bot` : bot Node.js.
- `postgres` : PostgreSQL + PostGIS.
- `redis` : cache, sessions, queues, cooldowns.

## Rôles de production

La stack utilise des profils Docker Compose :

- `web` : `nginx`, `app`, `ssr`, `reverb`.
- `data` : `postgres`, `redis`.
- `workers` : `queue`, `scheduler`, `discord-bot`.
- `tunnel` : `cloudflared` si tu choisis Cloudflare Tunnel au lieu d'exposer le port 80.

Le déploiement cible recommandé avec 3 VPS :

- VPS web public : profil `web`, derrière Cloudflare.
- VPS data privé : profil `data`, PostgreSQL/Redis bindés sur IP privée/VPN uniquement.
- VPS workers : profil `workers`, connectés à PostgreSQL/Redis via IP privée/VPN.

## Cloudflare

Deux options propres :

1. DNS proxied classique : `A arborisis.com -> IP publique du VPS web`, proxy orange actif, TLS `Full (strict)`.
2. Cloudflare Tunnel : créer un tunnel vers `http://nginx:80`, renseigner `CLOUDFLARE_TUNNEL_TOKEN`, puis lancer le profil `tunnel`.

Réglages Cloudflare conseillés :

- SSL/TLS : `Full (strict)`.
- Always Use HTTPS : actif.
- Minimum TLS : `1.2` ou `1.3`.
- Brotli : actif.
- HTTP/2 et HTTP/3 : actifs.
- WAF managed rules : actifs.
- Cache rule : cache agressif seulement pour `/build/*`, jamais pour les pages Laravel authentifiées.
- Rate limiting : protéger `/login`, `/register`, `/password/*`, `/api/*`, `/discord/*`, `/stripe/webhook`.

Nginx restaure l'IP visiteur via `CF-Connecting-IP` avec les ranges Cloudflare.

## Démarrage sur un seul VPS

Depuis la racine du repo :

```bash
cd infrastructure/docker
cp .env.example .env
docker compose --env-file .env build
docker compose --env-file .env up -d
docker compose --env-file .env exec app php artisan migrate --force
```

Les secrets applicatifs restent dans `arborisis/.env` et `arborisis/discord-bot/.env`.
Le fichier `infrastructure/docker/.env` ne sert qu'aux paramètres Docker et aux
valeurs partagées par Compose.
Les chemins `ARBORISIS_APP_ENV_FILE` et `ARBORISIS_DISCORD_ENV_FILE` permettent
de pointer chaque VPS vers son fichier d'environnement local.

Variables importantes dans `arborisis/.env` pour Docker :

```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://arborisis.com

DB_CONNECTION=pgsql
DB_HOST=postgres
DB_PORT=5432
DB_DATABASE=arborisis
DB_USERNAME=arborisis
DB_PASSWORD=<meme-valeur-que-POSTGRES_PASSWORD>

CACHE_STORE=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis
REDIS_HOST=redis

BROADCAST_CONNECTION=reverb
REVERB_HOST=arborisis.com
REVERB_PORT=443
REVERB_SCHEME=https
REVERB_SCALING_ENABLED=true
INERTIA_SSR_ENABLED=true
INERTIA_SSR_URL=http://ssr:13714
```

## Mise en production

```bash
cd infrastructure/docker
./deploy-local.sh data
./deploy-local.sh web
./deploy-local.sh workers
./deploy-local.sh backup
./deploy-local.sh migrate
```

Pour redémarrer uniquement les workers après un changement de code :

```bash
docker compose --env-file .env restart queue scheduler reverb
```

## Répartition sur 3 VPS

La stack est volontairement découpée pour pouvoir déplacer les rôles sans changer l'application.
Sur chaque VPS, garder un `infrastructure/docker/.env` local adapté au rôle.

### VPS 1 — Web public

Services :

```bash
./deploy-local.sh web
```

Dans `arborisis/.env`, pointer vers les IP privées ou VPN du VPS data :

```env
DB_HOST=10.0.0.2
REDIS_HOST=10.0.0.2
```

Cloudflare pointe vers ce VPS.

### VPS 2 — Data

Services :

```bash
POSTGRES_BIND_ADDR=10.0.0.2
REDIS_BIND_ADDR=10.0.0.2
./deploy-local.sh data
```

N'expose pas PostgreSQL ni Redis publiquement. Autorise seulement le réseau
privé/VPN entre VPS.

### VPS 3 — Workers

Services :

```bash
./deploy-local.sh workers
```

Même `arborisis/.env` que le VPS web, avec `DB_HOST` et `REDIS_HOST` vers le
VPS data. Les workers peuvent être scalés :

```bash
docker compose --env-file .env up -d --scale queue=3 queue
```

## Déploiement orchestré depuis un poste admin

Préparer le fichier :

```bash
cd infrastructure/docker
cp hosts.example hosts.prod
```

Puis renseigner :

```env
web=root@IP_VPS_WEB
data=root@IP_VPS_DATA
workers=root@IP_VPS_WORKERS
```

Déployer :

```bash
./deploy-remote.sh all
```

Le script synchronise le code sans écraser les fichiers `.env` de prod, démarre
les rôles dans l'ordre `data`, `web`, `workers`, crée un dump PostgreSQL sur le
VPS data, puis lance les migrations sur le VPS web.

## Audio analyzer

Le service d'analyse audio existe déjà dans `infrastructure/audio-analyzer-worker`.
Il peut être déployé sur un ou plusieurs VPS séparés et appelé via Cloudflare
Worker avec `ANALYZER_URLS`.

## Sécurité réseau recommandée

- Exposer publiquement uniquement `nginx` sur le VPS web.
- Garder PostgreSQL et Redis sur réseau privé ou VPN WireGuard/Tailscale.
- Bloquer les ports DB/cache depuis Internet.
- Si `POSTGRES_BIND_ADDR` ou `REDIS_BIND_ADDR` pointent vers une IP privée,
  firewall obligatoire pour n'autoriser que les VPS web/workers.
- Garder les clés S3/R2, Stripe et Discord uniquement dans les fichiers `.env`
  serveur, jamais côté client.
- Utiliser Cloudflare WAF/rate limiting devant le VPS web.
