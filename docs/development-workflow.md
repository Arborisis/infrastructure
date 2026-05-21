# Workflow de developpement Arborisis

Ce document complete `AGENTS.md`. Il decrit le chemin standard pour travailler proprement sur Arborisis sans fragiliser la production, la privacy GPS ou les integrations critiques.

## 1. Avant de commencer

1. Lire la demande et identifier le domaine touche : Laravel, Vue, audio, carte, ECHO, Discord, infra, docs.
2. Lire les fichiers existants concernes avant de modifier.
3. Verifier les regles dans `AGENTS.md`.
4. Choisir une branche courte :
   - `feature/nom-court`
   - `fix/nom-court`
   - `security/nom-court`
   - `docs/nom-court`
5. Lister les risques : donnees, migration, GPS, secrets, paiement, upload, performance, UX.

## 2. Regle de modification

Appliquer la plus petite modification utile. Ne pas melanger plusieurs intentions dans une meme PR.

Exemples :

- OK : corriger le payload carte pour supprimer une coordonnee exacte et ajouter un test Feature.
- Pas OK : corriger le payload carte, refactorer tous les controllers et changer le design de la page.

## 3. Commandes locales

Depuis `arborisis/` :

```bash
composer install
npm ci
cp .env.example .env
php artisan key:generate
```

Validation backend :

```bash
composer validate --strict
./vendor/bin/pint --test
php artisan test
```

Validation frontend :

```bash
npm run build
npm run lint       # si le script existe
npm run typecheck  # si le script existe
```

Validation securite :

```bash
composer audit
npm audit --omit=dev --audit-level=high
```

Validation Python audio si le changement touche `arborisis/python/` :

```bash
cd arborisis/python
pip install -r requirements.txt
python -m pytest tests/ -v
```

## 4. Strategy de tests

- Endpoint Laravel important : test Feature.
- Service critique : test Unit.
- Upload audio/image : validation MIME, taille, extension et erreur.
- ECHO/Stripe : transaction atomique, idempotence webhook et journal immutable.
- Carte/GPS : test qui verifie que les champs exacts ne sortent pas publiquement.
- UI : `npm run build` et verification manuelle mobile/desktop.
- CI/CD : verifier que le workflow echoue sur erreur reelle.

## 5. Pull Request

Une PR doit expliquer :

- objectif ;
- changements ;
- fichiers principaux ;
- tests effectues ;
- risques ;
- captures si UI ;
- checklist securite, privacy et performance.

Les commits suivent Conventional Commits :

```text
feat(audio): add waveform generation job
fix(map): hide exact GPS coordinates from public payload
security(upload): validate audio MIME type strictly
ci(github): add laravel test workflow
```

## 6. CI/CD GitHub

`ci.yml` valide :

- qualite backend Laravel ;
- build frontend ;
- tests Python audio ;
- audit composer/npm ;
- scan secrets ;
- garde-fous architecture/privacy ;
- resume final.

`security.yml` ajoute :

- scan secrets ;
- dependency review sur PR ;
- audit dependances ;
- CodeQL JavaScript/Python ;
- garde privacy sur les surfaces publiques.

`deploy-production.yml` :

- se lance uniquement manuellement ;
- refuse les branches autres que `main` ;
- utilise l'environnement GitHub `production` ;
- construit les assets ;
- reutilise les scripts de release atomique `.gitlab/deploy/` ;
- propose un rollback manuel vers la release precedente ou une release nommee.

## 7. Secrets GitHub production

Configurer dans GitHub Actions / Environments / `production` :

- `SSH_HOST`
- `SSH_USER`
- `SSH_PORT`
- `SSH_PRIVATE_KEY`
- `DEPLOY_PATH`
- `APP_URL`

Le fichier `.env` de production doit rester sur le serveur, dans le dossier partage attendu par le script de deploiement. Il ne doit jamais etre affiche dans les logs ni commite.

## 8. Checklist avant merge

- [ ] La PR suit `AGENTS.md`.
- [ ] Les changements sont limites et comprehensibles.
- [ ] Les tests pertinents sont ajoutes ou adaptes.
- [ ] `php artisan test` passe.
- [ ] `npm run build` passe.
- [ ] Pint passe.
- [ ] Les audits composer/npm sont traites ou justifies.
- [ ] Aucun secret n'est ajoute.
- [ ] Aucune coordonnee GPS exacte n'est exposee publiquement.
- [ ] Les migrations sont reversibles ou expliquees.
- [ ] La documentation est mise a jour si necessaire.
