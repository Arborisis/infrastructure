# Pipeline d'Analyse Audio Automatique — Arborisis

## Vue d'ensemble

Quand un utilisateur upload un fichier audio, le système déclenche automatiquement une analyse complète sans bloquer l'expérience utilisateur.

```
Upload Laravel
    ↓
R2 : sounds/original/{sound_id}/{filename}
    ↓
R2 Event Notification
    ↓
Cloudflare Queue : audio-analysis-queue
    ↓
Worker Cloudflare : audio-analysis-orchestrator
    ↓  (random + failover — ANALYZER_URLS)
Cloudflare Worker : audio-analyzer-container
    ↓
Cloudflare Containers : Python FastAPI
    ↓  (fallback possible pendant migration)
VPS Worker 1/2 : Nginx LB + 3× FastAPI
    ↓
Résultats dans R2 (waveform, spectrogram, features, birdnet, summary)
    ↓
Callback Laravel API interne
    ↓
Vue.js : AudioAnalysisPanel.vue
```

## Composants

### 1. Laravel — Upload & Orchestration

**Fichiers modifiés/créés :**
- `database/migrations/2026_05_10_201543_enrich_sound_analyses_table.php`
- `database/migrations/2026_05_10_201543_create_birdnet_detections_table.php`
- `app/Models/SoundAnalysis.php` — enrichi avec métadonnées audio, clés R2, qualité
- `app/Models/BirdnetDetection.php` — nouvelle table pour les détections
- `app/Enums/AnalysisStatus.php` — ajout de `queued`, `processing`
- `app/Services/AudioAnalysis/AudioAnalysisCallbackService.php` — traitement callback
- `app/Services/AudioAnalysis/AudioAnalysisOrchestrationService.php` — retry, URLs
- `app/Http/Controllers/Api/InternalAudioAnalysisController.php` — callback interne
- `app/Http/Middleware/VerifyInternalApiToken.php` — sécurité callback
- `app/Http/Requests/AudioAnalysis/CallbackRequest.php` — validation callback
- `app/Jobs/RequestAudioAnalysis.php` — job pour retry direct vers Analyzer
- `app/Events/AudioAnalysisCompleted.php`
- `app/Services/Sound/SoundUploadService.php` — upload dans `sounds/original/` sur R2

**Routes API :**
- `POST /api/internal/audio-analysis/callback` — callback sécurisé
- `GET /api/sounds/{sound}/analysis` — statut public
- `POST /api/sounds/{sound}/analysis/retry` — relancer (admin/propriétaire)

### 2. Service Python Analyzer

**Chemin :** `services/audio-analyzer/`

**Stack :** FastAPI, librosa, BirdNET, FFmpeg, boto3

**Endpoints :**
- `GET /health` — disponibilité
- `POST /analyze` — déclenche analyse asynchrone

**Scaling :** Le service est stateless. La cible privilégiée est Cloudflare Containers via `workers/audio-analyzer-container/`. Les VPS workers restent utilisables comme fallback ou comme déploiement alternatif, derrière un load balancer Nginx (`least_conn`). Voir `infrastructure/audio-analyzer-worker/`.

**Modules :**
- `metadata_extractor` — ffprobe
- `preview_generator` — ffmpeg MP3
- `waveform_generator` — librosa → JSON
- `spectrogram_generator` — matplotlib → WebP
- `feature_extractor` — librosa features
- `birdnet_runner` — classification espèces
- `quality_analyzer` — clipping, noise, label
- `summary_builder` — agrégation résultats
- `laravel_callback` — notification Laravel avec retry

### 3. Cloudflare Worker

**Chemin :** `workers/audio-analysis-orchestrator/`

Consomme la Queue `audio-analysis-queue`, filtre les fichiers audio, et appelle le service Python.

### 3b. Cloudflare Containers Gateway

**Chemin :** `workers/audio-analyzer-container/`

Expose `/health` et `/analyze`, puis route vers des instances Cloudflare Containers qui exécutent l'image Docker existante `services/audio-analyzer/`.

### 4. Vue.js — Interface

**Composant :** `resources/js/Components/AudioAnalysis/AudioAnalysisPanel.vue`

Affiche :
- Statut de l'analyse
- Métadonnées audio
- Spectrogramme
- Détections BirdNET avec barres de confiance
- Tags suggérés
- Qualité d'enregistrement
- Liens d'export JSON

## Stockage R2

```
sounds/original/{sound_id}/{filename}     ← fichier source
sounds/preview/{sound_id}/preview.mp3     ← preview générée
sounds/analysis/{sound_id}/waveform.json
sounds/analysis/{sound_id}/spectrogram.webp
sounds/analysis/{sound_id}/features.json
sounds/analysis/{sound_id}/birdnet.json
sounds/analysis/{sound_id}/summary.json
```

## Sécurité

| Couche | Mesure |
|--------|--------|
| Worker → Analyzer | Bearer token (`ANALYZER_SECRET`) |
| Analyzer → Laravel | Bearer token (`LARAVEL_API_SECRET`) |
| Laravel callback | Middleware `VerifyInternalApiToken` |
| R2 keys | Validation prefix, interdiction path traversal |
| Retry | Rate limit 5 req/min |

## Variables d'environnement

### Laravel (.env)

```env
ANALYZER_URL=https://analyzer.arborisis.com
ANALYZER_SECRET=<256-bit-token>
ANALYZER_INTERNAL_API_TOKEN=<256-bit-token>
AUDIO_MAX_DURATION=600
AUDIO_MAX_FILE_SIZE_MB=500
```

### Service Python (.env)

```env
ANALYZER_SECRET=<same-as-laravel>
LARAVEL_API_URL=https://arborisis.com
LARAVEL_API_SECRET=<same-as-laravel>
R2_ENDPOINT=...
R2_ACCESS_KEY_ID=...
R2_SECRET_ACCESS_KEY=...
R2_BUCKET=arborisis
BIRDNET_CONFIDENCE_THRESHOLD=0.5
```

### Worker (wrangler secret)

```
ANALYZER_URL
ANALYZER_SECRET
```

## Checklist de déploiement

### Phase 1 — Base de données
- [ ] `php artisan migrate`

### Phase 2 — Service Python / Containers
- [ ] `cd services/audio-analyzer && docker build -t arborisis-audio-analyzer .`
- [ ] Déployer `workers/audio-analyzer-container/` avec `wrangler deploy`
- [ ] Configurer les secrets Containers (`ANALYZER_SECRET`, `LARAVEL_API_SECRET`, R2...)
- [ ] Vérifier `/health`

### Phase 3 — Worker Cloudflare
- [ ] Créer les Queues `audio-analysis-queue` et `audio-analysis-dlq`
- [ ] Configurer R2 Event Notification sur `sounds/original/*`
- [ ] `wrangler deploy`
- [ ] `wrangler secret put ANALYZER_URL`
- [ ] `wrangler secret put ANALYZER_SECRET`

### Phase 4 — Laravel
- [ ] Ajouter les variables d'environnement
- [ ] `php artisan config:cache`
- [ ] `php artisan route:cache`

### Phase 5 — Frontend
- [ ] `npm run build`

### Phase 6 — Validation
- [ ] Uploader un fichier audio
- [ ] Vérifier le statut passe de `pending` → `processing` → `completed`
- [ ] Vérifier les fichiers dans R2
- [ ] Vérifier l'affichage Vue.js
- [ ] Tester le retry
