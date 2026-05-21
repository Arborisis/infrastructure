# Migration Contabo S3 → Cloudflare R2

## Résumé des modifications

- Nouveau disque `r2` dans `config/filesystems.php`
- Variables d'environnement `R2_*` ajoutées dans `.env` et `.env.example`
- Variable `AUDIO_DISK` pour basculer les uploads vers R2
- Commande artisan `storage:migrate-to-r2` pour migrer les fichiers existants
- Support du disque `r2` dans les modèles (`Sound`, `SoundVisualization`) et services (`RadioStreamService`, `SoundController`)
- **Worker Cloudflare** (`workers/r2-proxy/`) pour sécuriser l'accès via `storage.arborisis.com`
- **Signed URLs** avec HMAC-SHA256 pour les fichiers privés

## Variables d'environnement

```env
AUDIO_DISK=r2

R2_ACCESS_KEY_ID=<your-r2-access-key-id>
R2_SECRET_ACCESS_KEY=<your-r2-secret-access-key>
R2_DEFAULT_REGION=auto
R2_BUCKET=<your-r2-bucket>
R2_ENDPOINT=https://<account-id>.r2.cloudflarestorage.com
R2_USE_PATH_STYLE_ENDPOINT=true
R2_URL=https://<public-r2-domain>
R2_SIGNING_KEY=<generate-a-long-random-signing-key>
```

## Custom domain & Worker

Le bucket est exposé via `storage.arborisis.com` à travers un **Worker Cloudflare** qui vérifie les signatures HMAC.

### Architecture

```
Utilisateur → storage.arborisis.com/audio/3/xxx.wav?expires=...&signature=...
              ↓
         [Worker Cloudflare]
              ↓
    Vérification HMAC (expires + signature)
              ↓
    Si OK → Binding R2 → Fichier servi
    Si KO → 403 Forbidden
```

### Déploiement du Worker

```bash
cd workers/r2-proxy
npm install
wrangler login
wrangler secret put SIGNING_KEY
# Coller la valeur de R2_SIGNING_KEY du .env Laravel
wrangler deploy
```

Puis dans le dashboard Cloudflare :
1. Workers & Pages → `arborisis-r2-proxy`
2. Triggers → Custom Domains → Add Custom Domain → `storage.arborisis.com`
3. **Retirer le custom domain natif R2** du bucket (sinon conflit)

## Configuration CORS

Le CORS est configuré sur le bucket pour autoriser `https://*.arborisis.com`.

```bash
aws s3api get-bucket-cors \
  --bucket arborisis \
  --endpoint-url arborisis \
  --profile r2
```

## Migration des fichiers

### 1. Simulation (dry-run)

```bash
cd /var/www/arborisis/arborisis
php artisan storage:migrate-to-r2 --dry-run
```

### 2. Migration réelle

```bash
php artisan storage:migrate-to-r2
```

La commande copie :
- Les fichiers audio (`sound_files`)
- Les visualisations (`sound_visualizations`)
- Les covers (`sounds.cover_image`)

Elle met à jour le champ `disk` en base de données (`audio`/`s3` → `r2`).

### 3. Vérification

```bash
php artisan tinker
>>> \App\Models\SoundFile::where('disk', 'r2')->count();
>>> \App\Models\SoundFile::whereIn('disk', ['audio', 's3'])->count();
```

## Rollback

Si besoin de revenir en arrière, change `AUDIO_DISK` et restaure les anciennes valeurs `disk` en base :

```bash
php artisan tinker
>>> \App\Models\SoundFile::where('disk', 'r2')->update(['disk' => 'audio']);
```

## Post-migration

Une fois la migration validée, tu peux supprimer les variables AWS legacy :

```env
# À supprimer après validation complète
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_ENDPOINT=...
AWS_URL=...
```
