# Uptime Kuma — Monitoring Arborisis

## Vue d'ensemble

Ce dossier contient l'infrastructure pour déployer **Uptime Kuma** et monitorer l'ensemble des endpoints Arborisis sur `status.arborisis.com`.

---

## Déploiement rapide sur le VPS

### 1. Lancer Uptime Kuma (Docker)

```bash
cd /var/www/arborisis/infrastructure/uptime-kuma
docker compose up -d
```

Uptime Kuma est accessible localement sur `http://127.0.0.1:3001`.

### 2. Configurer Nginx (reverse proxy)

```bash
sudo cp nginx-status.conf /etc/nginx/sites-available/status.arborisis.com
sudo ln -s /etc/nginx/sites-available/status.arborisis.com /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 3. SSL (Certbot)

```bash
sudo certbot --nginx -d status.arborisis.com
```

### 4. Créer le compte admin Uptime Kuma

Rendez-vous sur `https://status.arborisis.com` et créez le compte administrateur lors du premier démarrage.

### 5. Créer la Status Page publique

Dans l'UI Uptime Kuma :

1. Allez dans **Status Pages → New Status Page**
2. **Slug** : `arborisis` (l'URL sera `https://status.arborisis.com/status/arborisis`)
3. **Titre** : `Arborisis — Statut des services`
4. **Description** : `Suivi en temps réel de la disponibilité des services Arborisis.`
5. Ajoutez tous les monitors importés ci-dessous dans la page
6. Publiez la page (icône 🌐 en haut à droite)

### 6. Importer les monitors

#### Option A — Script automatisé (recommandé)

```bash
export UK_HOST=https://status.arborisis.com
export UK_USERNAME=admin
export UK_PASSWORD=<votre_mot_de_passe>
export DISCORD_INTERNAL_API_TOKEN=<token_du_.env>
bash setup-monitors.sh
```

#### Option B — Import JSON manuel

Depuis l'UI Uptime Kuma : **Settings → Backup → Import** (format JSON de backup complet).

---

## Endpoints monitorés

| Monitor | URL | Intervalle | Critique |
|---------|-----|------------|----------|
| Laravel Health Check | `GET /api/health` | 60s | ✅ Oui |
| Landing Page | `GET /` | 120s | ✅ Oui |
| Sounds Page | `GET /sounds` | 120s | ✅ Oui |
| Map Page | `GET /map` | 120s | ✅ Oui |
| API — Map Sounds | `GET /api/map/sounds` | 60s | ✅ Oui |
| API — Map Search | `GET /api/map/sounds/search` | 120s | — |
| Radio Page | `GET /radio` | 120s | ✅ Oui |
| API — Radio Now Playing | `GET /api/radio/now-playing` | 60s | ✅ Oui |
| Creators Page | `GET /creators` | 120s | — |
| API — Scientific Stats | `GET /api/scientific-stats/global` | 120s | — |
| API — Arborisis Points | `GET /api/arborisis-points` | 120s | — |
| API — Quests | `GET /api/quests` | 120s | — |
| API — Achievements | `GET /api/achievements` | 120s | — |
| API — Medals | `GET /api/medals` | 120s | — |
| API — Map Presence | `GET /api/map/presence` | 120s | — |
| Transparency Page | `GET /transparency` | 300s | — |
| Auth — Login Page | `GET /login` | 300s | — |
| Contact Page | `GET /contact` | 300s | — |
| Mission Page | `GET /mission` | 300s | — |
| ECHO Info Page | `GET /echo` | 300s | — |
| API — VAPID Public Key | `GET /api/vapid-public-key` | 300s | — |
| Discord Bot Internal API | `GET /api/internal/discord/stats` | 60s | ✅ Oui |

---

## Health checks infra

L'endpoint `GET /api/health` vérifie explicitement :
- Connexion **PostgreSQL**
- Connexion **Redis**
- Stockage **S3** (Contabo)
- Espace disque

L'endpoint natif `GET /up` de Laravel reste disponible en fallback.

---

## Maintenance

### Mettre à jour Uptime Kuma

```bash
cd /var/www/arborisis/infrastructure/uptime-kuma
docker compose pull
docker compose up -d
```

### Sauvegarder les données

```bash
docker run --rm -v uptime-kuma-data:/data -v $(pwd):/backup alpine tar czf /backup/uptime-kuma-backup.tar.gz -C /data .
```

### Logs

```bash
docker logs -f uptime-kuma
```

---

## Sécurité

- Uptime Kuma n'écoute que sur `127.0.0.1:3001` — jamais exposé directement sur internet.
- L'accès public passe obligatoirement par Nginx + SSL.
- Le token Discord Internal API n'est jamais exposé côté client ; il est injecté dans les headers du monitor côté serveur Uptime Kuma uniquement.

---

## Architecture

```
Internet
    │
    ▼
status.arborisis.com (HTTPS / Nginx)
    │
    ▼
127.0.0.1:3001 (Uptime Kuma Docker)
    │
    ├───> GET https://arborisis.com/up
    ├───> GET https://arborisis.com/api/map/sounds
    ├───> GET https://arborisis.com/api/radio/now-playing
    └───> ... (tous les endpoints ci-dessus)
```
