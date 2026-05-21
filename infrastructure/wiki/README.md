# Wiki Arborisis — Infrastructure & Déploiement

Ce dossier contient toute l'infrastructure pour déployer **Wiki.js** comme documentation centrale d'Arborisis sur `wiki.arborisis.com`.

---

## Architecture

```
wiki.arborisis.com
    → Nginx (reverse proxy, SSL)
    → Wiki.js container (Node.js, port 3000)
    → PostgreSQL (schema wikijs, meme instance que Laravel)
    → Redis (optionnel, cache sessions)
```

## Fichiers

| Fichier | Description |
|---------|-------------|
| `docker-compose.wiki.yml` | Service Docker Wiki.js |
| `nginx/wiki.arborisis.com.conf` | Config Nginx reverse proxy |
| `init-wiki-db.sh` | Script d'init DB PostgreSQL |
| `.env.wiki.example` | Variables d'environnement exemple |
| `theme-arborisis.css` | Theme sombre custom (a injecter dans l'admin) |
| `README.md` | Ce fichier |

## Deploiement rapide

### 1. Initialiser la base de donnees

```bash
cd infrastructure/wiki
chmod +x init-wiki-db.sh
./init-wiki-db.sh
```

### 2. Configurer les variables d'environnement

Ajoutez dans votre `.env` principal (a la racine du projet) :

```env
# Wiki.js
WIKI_BIND_ADDR=127.0.0.1
WIKI_DB_NAME=wikijs
WIKI_DB_USER=wikijs
WIKI_DB_PASSWORD=votre-mot-de-passe-securise
WIKI_DB_SSL=false

# Admin Wiki.js (first-run)
WIKI_ADMIN_EMAIL=admin@arborisis.com
WIKI_ADMIN_PASSWORD=votre-mot-de-passe-admin

# OAuth2 SSO
WIKI_AUTH_OAUTH2_CLIENT_ID=arborisis-wiki
WIKI_AUTH_OAUTH2_CLIENT_SECRET=votre-secret-oauth
WIKI_AUTH_OAUTH2_AUTHORIZE_URL=https://arborisis.com/internal/wiki/oauth/authorize
WIKI_AUTH_OAUTH2_TOKEN_URL=https://arborisis.com/internal/wiki/oauth/token
WIKI_AUTH_OAUTH2_USER_INFO_URL=https://arborisis.com/internal/wiki/oauth/user
```

### 3. Lancer Wiki.js

```bash
cd infrastructure/docker
docker compose -f docker-compose.yml -f ../wiki/docker-compose.wiki.yml --profile wiki up -d wiki
```

Ou avec le profil `wiki` seul :

```bash
docker compose -f infrastructure/wiki/docker-compose.wiki.yml up -d
```

### 4. Configurer Nginx

Incluez la config dans votre Nginx principal :

```bash
sudo cp infrastructure/wiki/nginx/wiki.arborisis.com.conf /etc/nginx/conf.d/
sudo nginx -t
sudo systemctl reload nginx
```

### 5. SSL (Certbot)

```bash
sudo certbot --nginx -d wiki.arborisis.com
```

### 6. First-run setup

1. Rendez-vous sur `http://wiki.arborisis.com`
2. Creez le compte admin avec l'email defini dans `WIKI_ADMIN_EMAIL`
3. Dans l'admin : **Authentification → Ajouter une strategie → OAuth2**
4. Configurez avec les URLs du `.env`
5. Dans **Theme → Code Injection → CSS**, copiez le contenu de `theme-arborisis.css`

### 7. Importer le contenu

```bash
# Generer un token API dans l'admin Wiki.js
# Puis :
WIKI_API_URL=https://wiki.arborisis.com/graphql \
WIKI_API_TOKEN=votre-token \
node scripts/import-docs-to-wiki.js
```

## Mise a jour

```bash
docker compose -f infrastructure/wiki/docker-compose.wiki.yml pull
docker compose -f infrastructure/wiki/docker-compose.wiki.yml up -d
```

## Sauvegarde

Le contenu est dans PostgreSQL (schema `wikijs`). Sauvegardez avec :

```bash
pg_dump -h localhost -U wikijs -n wikijs wikijs > wiki-backup-$(date +%Y%m%d).sql
```

## Troubleshooting

| Probleme | Solution |
|----------|----------|
| "Cannot connect to database" | Verifier que le schema `wikijs` existe et que l'utilisateur a les droits |
| "Invalid redirect_uri" | Verifier la correspondance exacte entre Wiki.js et Laravel |
| Pages non importees | Verifier que `WIKI_API_TOKEN` est valide et que l'API GraphQL est accessible |
| Theme non applique | Vider le cache navigateur, verifier l'injection CSS dans l'admin |

## Ressources

- [Documentation Wiki.js](https://docs.requarks.io/)
- [API GraphQL Wiki.js](https://docs.requarks.io/dev/api)
- [SSO OAuth2](https://docs.requarks.io/auth/oauth2)
