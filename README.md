# Arborisis Infrastructure

<p align="center">
  <img src="https://raw.githubusercontent.com/Arborisis/.github/main/profile/logo.svg" alt="Arborisis Logo" width="150" />
</p>

<p align="center">
  <em>Infrastructure, deploiement et documentation pour la plateforme Arborisis.</em>
</p>

<p align="center">
  <a href="https://github.com/Arborisis/infrastructure/actions"><img src="https://img.shields.io/github/actions/workflow/status/Arborisis/infrastructure/ci.yml?branch=main&style=flat-square&label=CI" alt="CI" /></a>
  <a href="https://github.com/Arborisis/infrastructure/blob/main/LICENSE"><img src="https://img.shields.io/github/license/Arborisis/infrastructure?style=flat-square" alt="License" /></a>
</p>

---

## Overview

Ce repository centralise toute l'infrastructure de la plateforme Arborisis : Docker, CI/CD, documentation, et configurations de deploiement.

### Contenu

- **Docker** : Images et configurations Docker pour l'application
- **Infrastructure** : Configurations pour les services externes (radio, monitoring, wiki)
- **Documentation** : Guides de deploiement, architecture, workflows
- **CI/CD** : GitHub Actions et GitLab CI pour le build et le deploy

## Architecture de la plateforme

```
                    +------------------+
                    |   Cloudflare     |
                    |   (CDN/DNS)      |
                    +--------+---------+
                             |
                    +--------v---------+
                    |   Nginx Proxy    |
                    +--------+---------+
                             |
          +------------------+------------------+
          |                  |                  |
+---------v---------+ +------v------+ +--------v--------+
|   App Laravel     | |  Discord    | |  Audio Analyzer |
|   (PHP-FPM)       | |  Bot        | |  (FastAPI)      |
+-------------------+ +-------------+ +-----------------+
          |
+---------v---------+
|   PostgreSQL      |
|   + PostGIS       |
+-------------------+
          |
+---------v---------+
|   Redis           |
|   (Cache/Queue)   |
+-------------------+
```

## Services Docker

### Production

```bash
# Copier la configuration
cp .env.example .env
# Editer .env avec vos variables

# Lancer la stack
docker compose -f docker-compose.yml up -d
```

**Services :**
- `app` - Application Laravel (PHP-FPM)
- `nginx` - Reverse proxy
- `db` - PostgreSQL + PostGIS
- `redis` - Cache, sessions, queues
- `queue` - Workers Laravel
- `scheduler` - Cron Laravel
- `discord-bot` - Bot Discord (image GHCR)
- `python-analyzer` - Service d'analyse audio (image GHCR)

### Developpement

```bash
docker compose -f docker-compose.dev.yml up -d
```

## Infrastructure externe

### Radio

Diffusion radio en continu avec Liquidsoap :

```bash
cd infrastructure/radio
docker compose up -d
```

### Monitoring (Uptime Kuma)

```bash
cd infrastructure/uptime-kuma
docker compose up -d
```

### Wiki

```bash
cd infrastructure/wiki
docker compose up -d
```

### Audio Analyzer Worker

Load balancer pour le service d'analyse audio :

```bash
cd infrastructure/audio-analyzer-worker
docker compose up -d --build
```

## Deploiement

### GitHub Actions

- **CI** : Validation des configurations, build Docker
- **Build & Push** : Build et push des images vers GHCR
- **Deploy** : Deploiement automatique sur le VPS

### GitLab CI

Pipeline existante pour le deploiement (voir `.gitlab-ci.yml`).

### Manuel

```bash
# Build images
docker compose build

# Push vers GHCR
docker login ghcr.io -u USERNAME
docker push ghcr.io/Arborisis/app:latest

# Deploy sur le VPS
ssh user@server 'cd /opt/arborisis && docker compose pull && docker compose up -d'
```

## Documentation

- [Architecture](docs/architecture.md) - Architecture technique detaillee
- [Deploiement](docs/deploiement-gitlab-vps.md) - Guide de deploiement
- [Pipeline Audio](docs/audio-analysis-pipeline.md) - Pipeline d'analyse audio
- [Migration R2](docs/migration-r2.md) - Migration vers Cloudflare R2

## Repositories lies

- [app](https://github.com/Arborisis/app) - Application Laravel
- [discord-bot](https://github.com/Arborisis/discord-bot) - Bot Discord
- [audio-services](https://github.com/Arborisis/audio-services) - Services audio
- [workers](https://github.com/Arborisis/workers) - Workers Cloudflare

## License

[MIT License](LICENSE)
