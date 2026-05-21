# Deploiement GitLab CI vers un VPS

Ce projet se deploie avec GitLab CI via SSH + rsync. Le job `deploy_production`
envoie le dossier Laravel `arborisis/` vers une nouvelle release, puis le VPS
active atomiquement le lien `current`.

## Variables GitLab a configurer

Dans GitLab: `Settings > CI/CD > Variables`.

Variables obligatoires:

```text
DEPLOY_HOST=IP_OU_DOMAINE_DU_VPS
DEPLOY_USER=deploy
DEPLOY_PATH=/var/www/arborisis
SSH_PRIVATE_KEY=cle privee SSH du user deploy
```

Variables optionnelles:

```text
DEPLOY_PORT=22
DEPLOY_KEEP_RELEASES=5
PHP_BINARY=php
COMPOSER_BINARY=composer
RUN_MIGRATIONS=true
RUN_QUEUE_RESTART=true
```

Le job de production est manuel et ne se lance que depuis la branche par defaut.

## Preparation du VPS

Installer les dependances systeme adaptees a la distribution. Exemple Ubuntu:

```bash
sudo apt update
sudo apt install -y nginx redis-server postgresql-client unzip git composer ffmpeg \
  python3 python3-venv python3-pip \
  php-cli php-fpm php-pgsql php-redis php-intl php-zip php-xml php-curl php-mbstring php-bcmath
```

Creer un utilisateur de deploiement:

```bash
sudo adduser deploy
sudo usermod -aG www-data deploy
sudo mkdir -p /var/www/arborisis/{releases,shared}
sudo chown -R deploy:www-data /var/www/arborisis
sudo chmod -R 775 /var/www/arborisis
```

Ajouter la cle publique GitLab dans `/home/deploy/.ssh/authorized_keys`.

Creer le fichier d'environnement partage:

```bash
sudo -u deploy nano /var/www/arborisis/shared/.env
```

Points importants dans `.env`:

```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://arborisis.com
APP_KEY=base64:...

DB_CONNECTION=pgsql
CACHE_STORE=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis

FILESYSTEM_DISK=s3
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_DEFAULT_REGION=eu2
AWS_BUCKET=...
AWS_ENDPOINT=https://eu2.contabostorage.com
AWS_USE_PATH_STYLE_ENDPOINT=true

STRIPE_SECRET_KEY=...
STRIPE_WEBHOOK_SECRET=...
```

Pour generer une cle Laravel:

```bash
printf 'base64:%s\n' "$(openssl rand -base64 32)"
```

## Configuration Nginx

Le document root doit pointer vers le lien `current/public`:

```nginx
server {
    listen 80;
    server_name arborisis.com www.arborisis.com;

    root /var/www/arborisis/current/public;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php-fpm.sock;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

Selon la version installee, le socket peut etre par exemple
`/run/php/php8.3-fpm.sock`.

## Queue worker

Exemple Supervisor:

```ini
[program:arborisis-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/arborisis/current/artisan queue:work redis --sleep=3 --tries=3 --timeout=120
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=deploy
numprocs=1
redirect_stderr=true
stdout_logfile=/var/www/arborisis/shared/storage/logs/worker.log
stopwaitsecs=3600
```

Apres modification:

```bash
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start arborisis-worker:*
```

## VPS Workers dédiés (Audio Analyzer)

Pour isoler l'analyse audio (CPU-intensive) du serveur web, déployer le service
Python sur **un ou plusieurs VPS séparés**.

### Déploiement sur chaque VPS worker

Répéter l'opération sur **chaque** VPS worker (identique) :

```bash
# Sur le VPS worker (pas le VPS web)
sudo apt update && sudo apt install -y docker.io docker-compose-plugin git
sudo usermod -aG docker deploy

# Cloner le repo et déployer
git clone <repo> /var/www/arborisis
cd /var/www/arborisis/infrastructure/audio-analyzer-worker
cp ../../services/audio-analyzer/.env.example .env
# Éditer .env avec les secrets
sudo docker compose up -d --build
```

### Configuration du Cloudflare Worker (load balancing global)

Au lieu d'une seule URL, configurer la liste des workers dans le secret
`ANALYZER_URLS` :

```bash
cd workers/audio-analysis-orchestrator
wrangler secret put ANALYZER_URLS
# Valeur : https://worker1.arborisis.com,https://worker2.arborisis.com
```

Le Worker Cloudflare distribue aléatoirement les analyses entre les VPS et
bascule automatiquement sur un autre worker en cas de panne (5xx / timeout).

**Points clés :**
- Même configuration Docker Compose sur chaque VPS worker.
- Seul le port 80 (Nginx) est exposé publiquement sur chaque VPS.
- Aucune base de données ni Redis n'est nécessaire sur ces VPS.
- Voir `infrastructure/audio-analyzer-worker/README.md` pour le scaling par
  instance (3× FastAPI par VPS) et le script `deploy.sh`.

## Structure creee sur le VPS

```text
/var/www/arborisis
├── current -> releases/main-xxxx
├── releases/
└── shared/
    ├── .env
    ├── python-venv/
    └── storage/
```

`shared/.env`, `shared/storage` et `shared/python-venv` ne sont jamais remplaces
par GitLab.
