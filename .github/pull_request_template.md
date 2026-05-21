## Objectif

<!-- Expliquez en 1-3 phrases le probleme traite et le resultat attendu. -->

## Changements

- <!-- Changement 1 -->
- <!-- Changement 2 -->
- <!-- Changement 3 -->

## Fichiers principaux modifies

- <!-- Fichier principal -->

## Tests effectues

- [ ] `composer validate --strict`
- [ ] `./vendor/bin/pint --test`
- [ ] `php artisan test`
- [ ] `npm run build`
- [ ] `npm run lint` si disponible
- [ ] `npm run typecheck` si disponible
- [ ] Verification manuelle effectuee

## Risques

<!-- Donnees, migrations, performance, UX, compatibilite, deploiement. -->

## Captures / videos si UI

<!-- Ajouter avant/apres, mobile et desktop si pertinent. -->

## Checklist agent IA

- [ ] J'ai lu `AGENTS.md`.
- [ ] J'ai limite le changement a la plus petite modification utile.
- [ ] Je n'ai pas supprime de code sans justification.
- [ ] Je n'ai pas ajoute de dependance sans justification.
- [ ] J'ai documente les decisions d'architecture si necessaire.

## Checklist securite

- [ ] Aucun secret, token, cle API ou dump `.env`.
- [ ] Uploads valides cote serveur si concernes.
- [ ] Auth, policies et rate limiting verifies si endpoint sensible.
- [ ] Webhooks/signatures verifies si integration externe.
- [ ] Aucun log de donnee sensible.

## Checklist privacy Arborisis

- [ ] Aucune coordonnee GPS exacte dans une API ou UI publique.
- [ ] Les positions publiques utilisent des coordonnees approximees.
- [ ] Les lieux sensibles sont floutes/approximates.
- [ ] Les donnees utilisateur exposees sont minimales.

## Checklist performance

- [ ] Pas de requetes N+1 introduites.
- [ ] Index/migration ajoutes si nouveau filtre frequent.
- [ ] Jobs/queues utilises pour les traitements longs.
- [ ] Build frontend controle, bundle impact verifie si pertinent.

## Liens

Closes #
