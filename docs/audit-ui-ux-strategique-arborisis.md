# Audit UI/UX Arborisis

> **Date :** 2026-05-15  
> **Scope :** Analyse stratégique de l'interface utilisateur d'Arborisis (landing, navigation, carte, audio, communauté, ECHO, mobile, accessibilité)  
> **Stack :** Laravel 12 + Inertia.js + Vue 3 + Tailwind CSS + Leaflet + WaveSurfer.js  
> **Référence existante :** `audit-ux-frontend.md` (2026-05-14) — audit technique complémentaire  
> **Base d'analyse :** Code source local exploré + connaissance du site en production  

---

## 1. Résumé exécutif

1. **Arborisis a une identité visuelle de base solide** (fond sombre, accents verts, typographie Cormorant + DM Sans) mais manque de raffinement premium pour justifier son positionnement "archive sonore de la nature".
2. **La landing page manque de preuve sociale et de démonstration audio immédiate** — un visiteur n'entend aucun son dans les 10 premières secondes.
3. **La navigation guest souffre d'une surcharge cognitive** : deux cartes, trop d'entrées, pas de hiérarchie claire entre exploration et conversion.
4. **La carte sonore est techniquement bien construite** (clustering, popups, sidebar) mais son design visuel reste fonctionnel, pas immersif.
5. **Le lecteur audio manque d'une waveform visible en permanence** et d'une expérience "pleine page" digne d'une plateforme audio premium.
6. **Les crédits ECHO sont bien positionnés éthiquement** ("pas une cryptomonnaie") mais leur présence dans le parcours utilisateur est trop discrète.
7. **Le dashboard authentifié est surchargé** : stats, gamification, quêtes, activité, ECHO, astuces — tout sur une page sans hiérarchie claire.
8. **L'accessibilité a des fondations** (focus visible, reduced-motion) mais des lacunes critiques persistent (contraste des textes en opacité réduite, `alert()` natifs, aria-labels manquants).
9. **L'expérience mobile est correcte mais pas optimisée** : le mini-player empiète sur l'espace, la carte capture le scroll, les touch targets sont parfois justes.
10. **La promesse principale est claire** ("L'archive sonore de la nature") mais la preuve immédiate fait défaut — pas d'aperçu audio, pas de témoignage, pas de son en autoplay contrôlé.

---

## 2. Note globale

**Note globale : 64 / 100**

| Pilier | Note /20 | Justification |
|--------|----------|---------------|
| **Identité visuelle** | 12/20 | Bonne base (palette sombre, accents naturels) mais fragmentation, manque de raffinement, certains éléments ne respirent pas le "premium". |
| **UX (parcours)** | 12/20 | Parcours fonctionnels mais friction élevée : double carte, pas de démo audio immédiate, dashboard surchargé, gamification trop dense. |
| **Navigation** | 10/15 | Menus complets mais surchargés, confusion carte sonore vs carte communauté, manque de hiérarchie CTA. |
| **Accessibilité** | 9/15 | Focus visible et reduced-motion OK, mais contrastes faibles, `alert()` natifs, aria-labels insuffisants. |
| **Mobile** | 10/15 | Responsive fonctionnel, mais mini-player envahissant, carte qui capture le scroll, sidebar mobile perfectible. |
| **Conversion** | 11/15 | CTAs présents mais pas hiérarchisés, pas de preuve sociale, ECHO trop discret, pas de démo audio sur la landing. |

---

## 3. Ce qui fonctionne déjà bien

### 3.1 Design system sombre cohérent
- **Observation :** Le fond `arbor-night (#0B1220)`, le verre `arbor-glass`, les bordures subtiles et les accents `arbor-emerald (#34D399)` créent une atmosphère nocturne identifiable.
- **Pourquoi c'est positif :** Cela différencie Arborisis des plateformes audio généralistes (SoundCloud, Spotify) et ancre l'identité dans la nature.
- **Comment le renforcer :** Pousser le raffinement avec plus de profondeur (ombres portées subtiles, gradients de fond plus riches, textures organiques).

### 3.2 Typographie à deux voix
- **Observation :** Cormorant (serif) pour les titres, DM Sans pour le corps. C'est une combinaison élégante et poétique.
- **Pourquoi c'est positif :** Le contraste serif/sans-serif crée une hiérarchie naturelle et un ton "littéraire" adapté à une archive.
- **Comment le renforcer :** Utiliser Cormorant plus largement (hero, section titles, citations) et réserver DM Sans strictement au corps et aux labels.

### 3.3 Carte sonore interactive
- **Observation :** Clustering des pins, popups customisés, sidebar avec recherche et filtres, fly-to animation. C'est fonctionnellement abouti.
- **Pourquoi c'est positif :** L'exploration géographique est au cœur du concept et cette carte remplit son rôle.
- **Comment le renforcer :** Rendre les pins plus beaux (design organique), améliorer les popups, ajouter un mode "exploration immersive" plein écran.

### 3.4 Positionnement éthique d'ECHO
- **Observation :** Le copy "Pas une cryptomonnaie. Pas un investissement." est clair, visible sur la landing, et rassurant.
- **Pourquoi c'est positif :** Dans un contexte où tout système de crédit est suspect, cette transparence crée la confiance.
- **Comment le renforcer :** Intégrer ECHO plus naturellement dans le parcours de découverte d'un son (badge "Soutenir" sur la fiche son).

### 3.5 Support PWA et offline
- **Observation :** Prompt d'installation, bannière offline, service worker. C'est du soin apporté à l'expérience utilisateur.
- **Pourquoi c'est positif :** Pour une expérience audio mobile, le PWA est essentiel.
- **Comment le renforcer :** Améliorer le design des prompts PWA pour qu'ils soient plus harmonieux avec le reste.

---

## 4. Problèmes UI/UX détectés

### P0 — Problèmes critiques

| # | Problème | Impact utilisateur | Gravité | Solution recommandée |
|---|----------|-------------------|---------|---------------------|
| 1 | **Aucune démonstration audio sur la landing** | Le visiteur ne comprend pas ce qu'est un "son naturel" sans cliquer. Friction maximale. | Haute | Intégrer un lecteur audio ambient ou une grille de "sons du moment" directement sous le hero. |
| 2 | **Double carte = confusion cognitive** (`/map` vs `/arborisis-map`) | L'utilisateur ne sait pas laquelle choisir. Les noms sont trop proches. | Haute | Renommer clairement : "Carte des sons" vs "Carte des visites". Ou fusionner en une seule carte avec toggle de couche. |
| 3 | **Dashboard surchargé** (stats + gamification + quêtes + activité + ECHO + astuces) | Information overload. L'utilisateur ne sait pas où regarder en premier. | Haute | Refondre le dashboard avec des onglets ou des sections collapsibles. Privilégier l'action principale : publier/écouter. |
| 4 | **`alert()` natifs utilisés** (ArborisisMap, Sounds/Create) | Blocage brutal du thread, expérience cassée, inaccessible. | Haute | Remplacer par des toasts inline ou un composant `AlertBanner`. |
| 5 | **Navigation guest trop longue** (7 liens + séparateur + auth) | Le menu dépasse la largeur sur certains écrans. Trop de choix = pas de choix. | Haute | Réduire à 5 entrées maximum : Explorer, Carte, Sons, Créateurs, Radio. Regrouper le reste dans un menu "Plus". |

### P1 — Problèmes majeurs

| # | Problème | Impact utilisateur | Gravité | Solution recommandée |
|---|----------|-------------------|---------|---------------------|
| 6 | **Contraste insuffisant** (`text-arbor-sage/50`, `/60`, `/70`) | Texte illisible pour certains utilisateurs, non conforme WCAG AA. | Moyenne | Ne jamais descendre en dessous de `/70` pour du texte lisible. Vérifier systématiquement avec WebAIM. |
| 7 | **Mini-player audio sans waveform** | L'utilisateur ne voit pas la forme du son, l'expérience est moins immersive. | Moyenne | Ajouter une waveform miniature dans le mini-player, ou du moins un indicateur visuel de lecture. |
| 8 | **Pas de page profil créateur premium** | Les créateurs sont l'âme de la plateforme mais leur profil est basique (avatar initiale, stats simples). | Moyenne | Créer une page profil riche : bannière, bio, sons populaires, badges, localisation approximative. |
| 9 | **Scroll capturé par la carte sur mobile** | L'utilisateur est "bloqué" dans la carte quand il veut scroller la page. | Moyenne | Désactiver `scrollWheelZoom` sur mobile, activer seulement après un tap explicite. |
| 10 | **CTAs pas hiérarchisés** | "Explorer la carte" et "Publier un son" ont le même poids visuel sur la landing. | Moyenne | Établir une hiérarchie claire : CTA primaire (Explorer), secondaire (Écouter), tertiaire (Publier). |
| 11 | **Pas de preuve sociale** | Aucun témoignage, aucun "créateur mis en avant", aucun nombre d'écoutes visible sur la landing. | Moyenne | Ajouter une section "Créateurs en avant" avec avatars, noms, et leurs sons les plus populaires. |
| 12 | **Gamification trop visible sur le dashboard** | Quêtes, XP, médailles — cela peut rebuter les utilisateurs qui veulent juste écouter ou publier. | Moyenne | Rendre la gamification optionnelle/collapsible, ou la déplacer dans un onglet dédié. |

### P2 — Problèmes mineurs

| # | Problème | Impact utilisateur | Gravité | Solution recommandée |
|---|----------|-------------------|---------|---------------------|
| 13 | **Pas de skeleton screens** sur la carte et le dashboard | L'utilisateur voit du texte "Chargement..." ou des spinners basiques. | Basse | Implémenter des skeletons avec la classe `.skeleton` déjà définie. |
| 14 | **Icônes SVG inline partout** | Maintenance difficile, pas de système d'icônes unifié. | Basse | Adopter un système d'icônes (Heroicons via composant, ou Phosphor Icons). |
| 15 | **Particules animées excessives sur la landing** | Sur mobile ou reduced-motion, c'est du bruit visuel. | Basse | Réduire le nombre de particules à 6 max, ou les rendre optionnelles. |
| 16 | **Footer trop dense** | 4 colonnes dont certaines n'ont qu'un seul lien ("Aide" → Contact). | Basse | Simplifier le footer : 3 colonnes max, regrouper les liens secondaires. |

---

## 5. Recommandations prioritaires

### Priorité 1 — À corriger maintenant

1. **Ajouter une section audio sur la landing** : 3 à 6 sons mis en avant, jouables en un clic, sans inscription.
2. **Clarifier les deux cartes** : Renommer `/arborisis-map` en "Carte des visites" ou "Carte de communauté" avec un sous-titre explicite.
3. **Simplifier le dashboard** : Onglets ou sections collapsibles. Par défaut, montrer uniquement les actions rapides + les derniers sons.
4. **Remplacer tous les `alert()`** par des notifications inline stylisées.
5. **Réduire la navigation guest** : Explorer, Carte, Sons, Créateurs, Radio + CTA Rejoindre.
6. **Hiérarchiser les CTAs landing** : "Explorer la carte" (primary, plein), "Écouter un son" (secondary, contour), "Publier" (ghost).

### Priorité 2 — À améliorer ensuite

7. **Améliorer le mini-player** : Ajouter une waveform miniature, réduire la hauteur sur mobile.
8. **Créer des profils créateurs riches** : Bannière, bio formatée, grille de sons, badges, localisation.
9. **Ajouter une section preuve sociale** sur la landing : 3 créateurs mis en avant + leurs statistiques.
10. **Optimiser la carte mobile** : Désactiver le scroll wheel, améliorer le toggle sidebar.
11. **Créer un système d'icônes unifié** via un composant `AppIcon` avec toutes les icônes du projet.
12. **Ajouter des skeleton screens** sur la carte, le dashboard, et les listes de sons.

### Priorité 3 — À ajouter plus tard

13. **Mode "immersion" plein écran** sur la carte : cache tout sauf la carte et le lecteur audio.
14. **Visualisation audio enrichie** : Spectrogramme léger ou animation d'ondes sur le lecteur.
15. **Système de collections/listes de lecture** : Permettre aux utilisateurs de créer leurs propres playlists nature.
16. **Recherche globale** (Cmd+K) : Rechercher sons, créateurs, lieux, catégories.
17. **Page "Mission" plus narrative** : Scrollytelling avec photos et extraits sonores.

---

## 6. Nouvelle direction artistique proposée

### Palette

| Token | Couleur | Usage |
|-------|---------|-------|
| `arbor-night` | `#0B1220` | Fond principal |
| `arbor-deep` | `#0F172A` | Fond secondaire (cards, sections) |
| `arbor-charcoal` | `#1E293B` | Surfaces élevées |
| `arbor-moss` | `#4A6741` | Accent principal (boutons, liens) |
| `arbor-emerald` | `#34D399` | Accent vif (hover, états actifs, waveform) |
| `arbor-sage` | `#8FA68E` | Texte secondaire |
| `arbor-cream` | `#F3F0E7` | Texte principal |
| `arbor-amber` | `#D4A574` | Accent ECHO, or |
| `arbor-glass` | `rgba(255,255,255,0.03)` | Surfaces translucides |
| `arbor-glass-border` | `rgba(255,255,255,0.06)` | Bordures subtiles |

### Typographie
- **Titres :** Cormorant, 400/600/700. Utiliser le gras avec parcimonie (uniquement hero et CTA).
- **Corps :** DM Sans, 400/500. Taille minimum 14px (16px recommandé pour le mobile).
- **Données :** JetBrains Mono, 400. Durées, stats, soldes ECHO.
- **Hiérarchie :** Hero 48-64px, H2 32-40px, H3 20-24px, body 16px, caption 14px.

### Boutons
- **Primary :** `bg-arbor-moss`, texte blanc, `rounded-xl` (16px), padding 14px 28px, hover `bg-arbor-moss-light` + ombre douce.
- **Secondary :** Bordure `arbor-glass-border`, fond transparent, hover `bg-arbor-glass`.
- **Ghost :** Texte `arbor-sage`, hover `arbor-cream`, pas de fond.
- **CTA audio :** `bg-arbor-emerald`, texte `arbor-night`, forme circulaire (play/pause).

### Cards
- **Glass card :** `backdrop-blur-xl`, fond `arbor-glass`, bordure `arbor-glass-border`, radius 20px.
- **Sound card :** Image 16:9 en haut, overlay play au hover, metadata en bas.
- **Creator card :** Avatar rond, nom, statistiques clés, badge "Soutenir".

### Header
- **Desktop :** Transparent sur le hero, fond `arbor-night/80 backdrop-blur-xl` au scroll. Logo à gauche, 5 liens centraux, CTA "Rejoindre" à droite.
- **Mobile :** Logo + hamburger. Menu slide-in depuis la droite avec fond `arbor-deep/95`.

### Carte
- **Tiles :** Fond sombre (CartoDB Dark Matter ou style personnalisé plus vert).
- **Pins :** Forme organique (goutte d'eau/ feuille), couleur par catégorie, halo pulsant subtil.
- **Cluster :** Cercle avec nombre, fond `arbor-emerald/80`, texte `arbor-night`.
- **Popup :** Glassmorphism, image cover, titre, créateur, CTA "Écouter".

### Lecteur audio
- **Plein écran :** Image cover floutée en fond, waveform centrée, contrôles minimalistes.
- **Mini :** Barre fixe en bas, waveform fine, titre + créateur, play/pause, volume.
- **Waveform :** Couleur `arbor-emerald`, fond `arbor-charcoal`, barres arrondies.

### Iconographie
- **Style :** Stroke 1.5px, taille 20-24px, couleur `arbor-sage` (inactive) / `arbor-cream` (active).
- **Librairie :** Heroicons 24px outline, ou Phosphor Icons (plus organiques).

### Animations
- **Principe :** Calme, fluide, jamais agressif.
- **Durées :** 200-300ms pour les interactions, 500-800ms pour les apparitions.
- **Easing :** `cubic-bezier(0.4, 0, 0.2, 1)` pour les transitions.
- **Hover :** `translateY(-2px)` + ombre douce sur les cards.
- **Réduit :** Respect strict de `prefers-reduced-motion`.

### Ambiance générale
> *"Une nuit dans une forêt. Le silence n'est pas vide. Chaque son est une fenêtre sur un paysage."*

- Fonds profonds avec des gradients radial subtils (vert/moss, très faible opacité).
- Textures de grain organique (2-3% d'opacité) sur les sections pleines.
- Pas de néons, pas de couleurs saturées. Tout doit respirer.

---

## 7. Refonte proposée de la page d'accueil

### Structure

```
1. Header (sticky, transparent → blur au scroll)
2. Hero Section (plein écran, image nature + particules subtiles)
3. Démonstration audio (grille de 6 sons jouables)
4. Carte sonore interactive (preview embed, CTA pleine carte)
5. Comment ça marche (3 étapes, visuelles)
6. Créateurs en avant (3 profils + stats)
7. Crédits ECHO (carte explicative, transparente)
8. Mission écologique et sonore (texte poétique + CTA)
9. Communauté (stats animées, témoignages)
10. CTA final ("Rejoindre l'archive")
11. Footer (simplifié, 3 colonnes)
```

### Détail par section

#### 1. Header
- **Objectif :** Navigation claire sans distraction.
- **Contenu :** Logo | Sons | Carte | Créateurs | Radio | Connexion | Rejoindre
- **Design :** Hauteur 64px, transparent au-dessus du hero, `bg-arbor-night/70 backdrop-blur-xl` dès le scroll.
- **CTA :** "Rejoindre" en `btn-primary` compact.

#### 2. Hero Section
- **Objectif :** Comprendre Arborisis en 3 secondes + donner envie d'explorer.
- **Contenu :**
  - Titre : *"L'archive sonore du monde vivant"*
  - Sous-titre : *"Explorez, écoutez et préservez les sons de la nature, capturés par une communauté de field recorders passionnés."*
  - CTA primaire : *"Explorer la carte sonore"*
  - CTA secondaire : *"Écouter les derniers sons"*
- **Design :** Image nature full-bleed, overlay gradient nuit, titre Cormorant 56px (desktop), particules réduites à 6 max.
- **Composants :** `HeroSection`, `ParticleField` (optimisé).

#### 3. Démonstration audio
- **Objectif :** Prouver la valeur immédiatement. Un visiteur doit entendre un son en 1 clic.
- **Contenu :** 6 sons mis en avant (tendance + diversité : forêt, océan, montagne, rivière, urbain, nuit).
- **Design :** Grille 3 colonnes desktop, 2 tablette, 1 mobile. Cards `glass-card` avec image cover, bouton play overlay, titre, créateur, durée.
- **CTA :** "Découvrir tous les sons →"
- **Composants :** `SoundCard`, `AudioPlayer` (mini intégré).

#### 4. Carte sonore interactive
- **Objectif :** Montrer l'ampleur de l'archive et donner envie d'explorer.
- **Contenu :** Embed de la carte avec ~50 pins, sidebar réduite (juste recherche + 3 catégories populaires).
- **Design :** `aspect-[16/9]` desktop, `aspect-[4/3]` mobile. Bordure `arbor-glass-border`, radius 20px. Overlay "Ouvrir la carte en plein écran" au hover.
- **CTA :** "Ouvrir la carte" (primary)
- **Composants :** `SoundMap` (mode embed).

#### 5. Comment ça marche
- **Objectif :** Rassurer, expliquer la simplicité.
- **Contenu :**
  - *1. Explorez* — "Naviguez sur la carte ou parcourez les catégories."
  - *2. Écoutez* — "Lancez la lecture et laissez-vous transporter."
  - *3. Partagez* — "Publiez vos propres enregistrements et soutenez les créateurs."
- **Design :** 3 cards alignées, numéros en Cormorant 48px, icônes fines.
- **Composants :** `StepCard`.

#### 6. Créateurs en avant
- **Objectif :** Humaniser la plateforme, créer de l'aspiration.
- **Contenu :** 3 créateurs avec avatar, nom, localisation approximative, nombre de sons, son le plus populaire.
- **Design :** Cards horizontales (avatar à gauche, info à droite) ou verticales selon l'espace.
- **CTA :** "Voir tous les créateurs →"
- **Composants :** `CreatorCard`.

#### 7. Crédits ECHO
- **Objectif :** Expliquer le système de soutien sans le rendre technocratique.
- **Contenu :** Logo E, titre "Soutenez les créateurs", texte "Les crédits ECHO vous permettent de remercier directement les enregistreurs. Simple, transparent, sans intermédiaire.", répartition visuelle (70/20/10).
- **Design :** Card centrée, large max, fond légèrement différent (`arbor-deep/50`).
- **CTA :** "Découvrir ECHO" (secondary)
- **Composants :** `EchoCreditCard`.

#### 8. Mission écologique et sonore
- **Objectif :** Créer un lien émotionnel et justifier l'existence d'Arborisis.
- **Contenu :** Texte poétique court + 3 engagements (Respect de la nature, Confidentialité, Transparence).
- **Design :** Fond plein (`arbor-deep`), texte centré, icônes petites et fines.
- **Composants :** `MissionSection`.

#### 9. Communauté
- **Objectif :** Montrer la vitalité de la communauté.
- **Contenu :** Stats animées (sons, créateurs, pays) + 1-2 témoignages courts.
- **Design :** Stats en grande typographie Cormorant, témoignages en italique.
- **Composants :** `StatCounter`, `TestimonialCard`.

#### 10. CTA final
- **Objectif :** Convertir les hésitants.
- **Contenu :** *"Rejoignez la communauté"* + *"Créez votre profil, publiez vos premiers enregistrements et connectez-vous avec d'autres passionnés."*
- **CTA :** "Créer un compte gratuit" (primary) | "J'ai déjà un compte" (secondary)
- **Composants :** `CTASection`.

#### 11. Footer
- **Objectif :** Navigation secondaire + newsletter.
- **Contenu :**
  - Colonne 1 : Logo + tagline + newsletter
  - Colonne 2 : Explorer (Sons, Carte, Créateurs, Radio)
  - Colonne 3 : À propos (Mission, Charte, ECHO, Contact)
- **Design :** 3 colonnes max, texte 14px, liens `arbor-sage` hover `arbor-emerald`.
- **Composants :** `AppFooter`, `NewsletterForm`.

---

## 8. Amélioration du header

### Navigation desktop (Guest)

```
[Logo Arborisis]    Sons    Carte    Créateurs    Radio    Plus ▼    |    Connexion    [Rejoindre]
```

- **Sons** → `/sounds`
- **Carte** → `/map` (avec label explicite "Carte des sons" dans le dropdown si fusion)
- **Créateurs** → `/creators`
- **Radio** → `/radio`
- **Plus ▼** → Chroniques, Mission, Charte, Contact
- **Connexion** → lien texte
- **Rejoindre** → `btn-primary`

### Navigation desktop (Authenticated)

```
[Logo]    Explorer ▼    Publier    Enregistrer    |    [Avatar + Nom ▼]
```

- **Explorer ▼** : Sons naturels, Carte des sons, Carte communauté, Créateurs, Radio, Chroniques
- **Publier** → `/sounds/create`
- **Enregistrer** → `/sounds/record`
- **Avatar** : Dropdown avec Profil, Paramètres, Déconnexion

### Navigation mobile

- **Menu slide-in** depuis la droite (pas de dropdown brut).
- **Sections séparées** : Explorer | Publier | Mon compte
- **CTA "Rejoindre"** sticky en bas du menu si non connecté.

### Comportement
- **Sticky** toujours.
- **Transparent** sur le hero (landing non connecté), `backdrop-blur` dès le scroll.
- **Réduction de hauteur** au scroll : 64px → 56px pour gagner de l'espace.

---

## 9. Amélioration de la carte sonore

### Interface complète

#### Sidebar (desktop)
- **Largeur :** 380px fixe, collapsible.
- **Sections :**
  1. **Recherche** : Input avec icône, clear button, placeholder "Rechercher un son, un lieu, un créateur..."
  2. **Filtres rapides** : Pills par catégorie (Forêts, Océans, Montagnes, etc.), couleur codée.
  3. **Résultats** : Liste scrollable, item = thumbnail + titre + créateur + durée.
  4. **État vide poétique** : "Ce territoire est encore silencieux. Soyez le premier à l'explorer."

#### Pins
- **Forme :** Goutte d'eau ou feuille stylisée (pas de cercle basique).
- **Couleur :** Par catégorie (12 catégories = 12 teintes naturelles).
- **États :** Normal (subtil), hover (scale 1.2 + glow), actif (scale 1.4 + halo animé).
- **Animation :** Halo pulsant très lent (4s), opacité 10%.

#### Cluster
- **Forme :** Cercle avec fond `arbor-emerald/85`, texte `arbor-night` gras.
- **Comportement :** Au clic, zoom progressif + dépliage spiderfy si nécessaire.

#### Panel de détail (popup)
- **Design :** Glassmorphism, radius 16px, ombre forte.
- **Contenu :** Cover image (110px), badge catégorie, titre, créateur, lieu approximatif, durée, CTA "Écouter".
- **Action :** Au clic sur "Écouter", lancement dans le mini-player + fly-to sur la carte.

#### Mode mobile
- **Sidebar :** Drawer slide-up depuis le bas, hauteur 60% de l'écran.
- **Toggle :** FAB (Floating Action Button) en bas à droite pour ouvrir/fermer.
- **Carte :** Plein écran, gestures tactiles optimisées.

#### États
- **Chargement :** Skeleton de la sidebar + spinner subtil sur la carte.
- **Vide :** Illustration + texte poétique + CTA "Publier un son ici".
- **Erreur :** Message inline, pas d'`alert()`.

---

## 10. Amélioration du lecteur audio

### Version pleine page (fiche son)

```
+--------------------------------------------------+
|  [Cover image 16:9]                              |
|  [Overlay : titre + créateur + play géant]       |
+--------------------------------------------------+
|  [Waveform WaveSurfer — hauteur 100px]           |
|  [----o========================================]  |
|  0:24                              4:32          |
+--------------------------------------------------+
|  [❤️ J'aime]  [🔗 Partager]  [🏳️ Signaler]      |
+--------------------------------------------------+
```

- **Layout :** Cover en haut, waveform centrée, contrôles sous la waveform.
- **Waveform :** Barres arrondies, couleur `arbor-emerald`, fond `arbor-charcoal`. Hauteur 80-100px.
- **Contrôles :** Play/Pause circulaire (48px), volume, partage, like.
- **Metadata :** Titre en `font-display` 24px, créateur cliquable, tags, description.
- **Interactions :** Click sur la waveform = seek. Hover sur la barre de progression = tooltip temps.

### Version mini-player (global)

```
+--------------------------------------------------+
| [▶]  Titre du son — Créateur    [════o══]  [🔊] [✕] |
+--------------------------------------------------+
```

- **Layout :** Barre fixe en bas (hauteur 64px desktop, 56px mobile).
- **Waveform :** Fine (hauteur 24px), visible en permanence pendant la lecture.
- **Info :** Titre tronqué, créateur, cliquable vers la fiche.
- **Contrôles :** Play/Pause (36px), volume (slider compact), fermeture.
- **Mobile :** Réduire à : Play/Pause + Titre + barre de progression fine + fermeture. Volume dans un menu secondaire.

### Design général
- **Couleurs :** Fond `arbor-deep/95 backdrop-blur-xl`, bordure top `arbor-glass-border`.
- **Transitions :** Apparition `translateY(100%) → 0`, 300ms ease-out.
- **Media Session API :** Déjà implémenté — parfait, conserver.

---

## 11. Amélioration mobile

| Élément | Problème actuel | Solution |
|---------|----------------|----------|
| **Header** | Trop de liens visibles, logo petit | Réduire à 3 liens + menu "Plus". Logo 40px. |
| **Hero** | Titre trop grand (5xl), CTA superposés | Titre 36px max. CTAs empilés, pleine largeur. |
| **Carte** | Scroll capturé par Leaflet | `scrollWheelZoom: false` par défaut. Tap-to-enable. |
| **Sidebar carte** | Overlay mal positionné, difficile à fermer | Drawer bottom-sheet avec poignée de drag. |
| **Mini-player** | Trop haut, cache le contenu | 56px de haut. Volume caché dans un menu. |
| **Boutons** | Certains < 44px de hauteur | Tous les boutons interactifs ≥ 44px. |
| **Texte** | Taille minimum 14px, parfois 12px | Corps 16px minimum. Caption 14px. |
| **Formulaires** | Inputs pleine largeur mal espacés | Padding 16px latéral. Espacement vertical 24px. |
| **Filtres** | Pills trop petits, difficiles à toucher | Pills hauteur 40px minimum, espacement 8px. |
| **Audio** | Pas de prévisualisation facile | Bouton play sur toute la card, zone cliquable 48px. |

### Navigation mobile recommandée
- **Menu hamburger** → slide-in depuis la droite.
- **Sections :** Explorer (Sons, Carte, Créateurs), Publier (Publier, Enregistrer), Compte (Profil, Paramètres).
- **CTA sticky** : "Rejoindre" en bas du menu si non connecté.

---

## 12. Accessibilité

### Checklist WCAG 2.1 AA

- [ ] **Contraste :** Tout texte lisible doit avoir un ratio ≥ 4.5:1. Ne pas utiliser `text-arbor-sage` en dessous de 70% d'opacité.
- [ ] **Tailles de police :** Corps minimum 16px sur mobile (évite le zoom iOS). Caption minimum 14px.
- [ ] **Focus visible :** Déjà OK (`outline: 2px solid #34D399`). Vérifier qu'il n'est jamais supprimé (`outline-none` sauf si remplacé).
- [ ] **Clavier :** Tous les éléments interactifs doivent être atteignables avec Tab. Pas de piège au clavier.
- [ ] **Alt text :** Images informatives = descriptif. Images décoratives = `alt=""`. Covers de sons = `alt="Couverture de [titre]"`.
- [ ] **Labels :** Tout bouton icon-only doit avoir `aria-label`. Tout input doit avoir un `<label>` associé.
- [ ] **ARIA :** Utiliser `aria-expanded` sur les menus, `aria-live` sur les notifications, `aria-invalid` sur les champs en erreur.
- [ ] **États interactifs :** hover, focus, active, disabled doivent tous être visuellement distincts.
- [ ] **Motion :** Respecter `prefers-reduced-motion` pour TOUTES les animations (CSS + JS).
- [ ] **Landmarks :** `<nav>`, `<main>`, `<footer>`, `<section>` avec `aria-label` si multiples.

### Corrections prioritaires
1. Remplacer tous les `alert()` par des toasts/accessibles.
2. Ajouter `aria-label` sur tous les boutons SVG-only.
3. Corriger les contrastes des placeholders et textes secondaires.
4. Ajouter `aria-invalid` et `aria-describedby` aux inputs en erreur.

---

## 13. Design system recommandé

### Couleurs (tokens Tailwind)

```js
// tailwind.config.js
colors: {
  arbor: {
    night:    '#0B1220',
    deep:     '#0F172A',
    charcoal: '#1E293B',
    moss:     '#4A6741',
    'moss-light': '#5a7d4f',
    emerald:  '#34D399',
    'emerald-dark': '#10B981',
    sage:     '#8FA68E',
    cream:    '#F3F0E7',
    'cream-dark': '#E8E4D9',
    glass:    'rgba(255,255,255,0.03)',
    'glass-border': 'rgba(255,255,255,0.06)',
    amber:    '#D4A574',
    'amber-glow': '#C9842B',
  },
}
```

### Typographies

```js
fontFamily: {
  sans: ['DM Sans', 'system-ui', 'sans-serif'],
  display: ['Cormorant', 'Georgia', 'serif'],
  mono: ['JetBrains Mono', 'monospace'],
}
```

### Espacements
- **Section padding :** `px-4 sm:px-6 lg:px-8 xl:px-12`
- **Section vertical :** `py-16 sm:py-20 lg:py-24`
- **Grid gap :** `gap-4 sm:gap-6 lg:gap-8`
- **Card padding :** `p-5 sm:p-6 lg:p-8`

### Radius
- **Buttons :** `rounded-xl` (16px)
- **Cards :** `rounded-2xl` (20px)
- **Inputs :** `rounded-xl` (16px)
- **Avatars :** `rounded-full`
- **Badges :** `rounded-lg` (8px)

### Ombres
- **Card hover :** `shadow-lg shadow-black/20`
- **Card premium :** `shadow-xl shadow-black/30`
- **Glow emerald :** `shadow-emerald-500/10`
- **Glow moss :** `shadow-moss/10`

### Boutons

```css
.btn-primary {
  @apply inline-flex items-center justify-center px-7 py-3.5 bg-arbor-moss hover:bg-arbor-moss-light text-white font-medium rounded-xl transition-all duration-200;
  @apply hover:shadow-lg hover:shadow-arbor-moss/20 focus:ring-2 focus:ring-arbor-emerald focus:ring-offset-2 focus:ring-offset-arbor-night;
  @apply active:scale-[0.98] disabled:opacity-50 disabled:cursor-not-allowed;
}

.btn-secondary {
  @apply inline-flex items-center justify-center px-7 py-3.5 bg-transparent border border-arbor-glass-border hover:bg-arbor-glass text-arbor-cream font-medium rounded-xl transition-all duration-200;
  @apply focus:ring-2 focus:ring-arbor-sage focus:ring-offset-2 focus:ring-offset-arbor-night;
  @apply active:scale-[0.98];
}

.btn-ghost {
  @apply inline-flex items-center justify-center px-4 py-2 bg-transparent text-arbor-sage hover:text-arbor-cream transition-colors duration-200;
}

.btn-audio {
  @apply w-12 h-12 rounded-full bg-arbor-emerald hover:bg-arbor-emerald-dark flex items-center justify-center text-arbor-night transition-all duration-200;
  @apply hover:shadow-lg hover:shadow-arbor-emerald/30 active:scale-95;
}
```

### Cards

```css
.glass-card {
  @apply bg-arbor-glass backdrop-blur-xl border border-arbor-glass-border rounded-2xl;
}

.sound-card {
  @apply glass-card overflow-hidden transition-all duration-300 hover:-translate-y-0.5 hover:shadow-lg hover:shadow-black/20;
}

.creator-card {
  @apply glass-card p-6 transition-all duration-300 hover:-translate-y-0.5 hover:shadow-lg hover:shadow-black/20;
}
```

### Badges

```css
.badge {
  @apply inline-flex items-center px-2.5 py-1 rounded-lg text-xs font-medium;
}

.badge-emerald { @apply bg-arbor-emerald/15 text-arbor-emerald; }
.badge-amber   { @apply bg-arbor-amber/15 text-arbor-amber; }
.badge-sage    { @apply bg-arbor-sage/15 text-arbor-sage; }
```

### Forms

```css
.input-field {
  @apply w-full bg-arbor-charcoal border border-arbor-fog rounded-xl px-4 py-3 text-arbor-cream placeholder:text-arbor-sage/60;
  @apply focus:border-arbor-emerald/50 focus:ring-2 focus:ring-arbor-emerald/10 transition-all duration-200;
}

.input-error {
  @apply border-red-500 focus:border-red-500 focus:ring-red-500/20;
}
```

### Modals
- **Backdrop :** `bg-black/60 backdrop-blur-sm`
- **Panel :** `glass-card max-w-lg mx-auto`
- **Animation :** `opacity-0 scale-95 → opacity-100 scale-100`, 200ms

### Alerts / Toasts
- **Success :** Bordure `arbor-emerald/30`, fond `arbor-emerald/10`, icône `arbor-emerald`
- **Error :** Bordure `red-500/30`, fond `red-500/10`, icône `red-400`
- **Info :** Bordure `arbor-sage/30`, fond `arbor-sage/10`, icône `arbor-sage`

### Empty States
- **Icon :** 48-64px, couleur `arbor-sage/30`
- **Titre :** `font-display` 20px, `arbor-cream`
- **Description :** 14px, `arbor-sage`
- **CTA :** `btn-primary` ou `btn-secondary` si optionnel

### Loading States
- **Skeleton :** `bg-arbor-charcoal` avec shimmer (déjà défini).
- **Spinner :** Bordure 2px, `arbor-emerald`, `animate-spin`.
- **Waveform loader :** 5 barres animées en cascade (déjà utilisé dans la carte).

---

## 14. Composants UI à créer

| Composant | Rôle | Props principales | États | Remarques UX |
|-----------|------|-------------------|-------|-------------|
| `AppHeader` | Navigation globale | `variant: 'guest' \| 'auth'`, `scrolled: boolean` | transparent, blurred | Réduction de hauteur au scroll |
| `AppFooter` | Footer global | — | — | 3 colonnes max |
| `HeroSection` | Hero landing | `title`, `subtitle`, `ctas[]`, `backgroundImage` | — | Particules optionnelles, réduites |
| `SoundCard` | Card son jouable | `sound`, `showPlayButton`, `size` | default, hover, playing | Play overlay au hover, waveform mini |
| `SoundGrid` | Grille de sons | `sounds[]`, `columns` | loading, empty, populated | Skeletons pendant le chargement |
| `SoundMap` | Carte interactive | `sounds[]`, `mode: 'full' \| 'embed'`, `activeSoundId` | loading, empty, error | Mode embed = controls réduits |
| `MapSidebar` | Sidebar carte | `sounds[]`, `categories[]`, `searchQuery` | loading, empty, filtered | Drawer mobile bottom-sheet |
| `MapPin` | Pin personnalisé | `category`, `isActive`, `isHovered` | default, hover, active | Forme organique, halo pulsant |
| `AudioPlayer` | Lecteur plein écran | `sound`, `audioUrl` | loading, playing, paused, ended | Waveform WaveSurfer intégré |
| `MiniPlayer` | Lecteur global fixe | — (utilise Pinia store) | hidden, visible, playing | Waveform fine, hauteur réduite mobile |
| `CreatorCard` | Card créateur | `creator`, `featuredSound` | default, hover | Avatar, stats, badge "Soutenir" |
| `CreatorProfile` | Page profil créateur | `creator`, `sounds[]`, `stats` | loading, empty, populated | Bannière, bio, grille de sons |
| `EchoCreditCard` | Explication ECHO | `balance?`, `showCTA` | default | Répartition visuelle 70/20/10 |
| `BadgeCard` | Badge/succès | `badge`, `unlocked`, `progress` | locked, unlocked | Opacité réduite si verrouillé |
| `QuestCard` | Quête active | `quest`, `progress` | active, completed | Barre de progression, CTA |
| `FilterPill` | Filtre catégorie | `label`, `color`, `active` | active, inactive | Couleur codée, min-height 40px |
| `SearchInput` | Input recherche | `modelValue`, `placeholder`, `clearable` | empty, filled, loading | Icône loupe, clear button |
| `EmptyState` | État vide | `icon`, `title`, `description`, `cta?` | — | Ton poétique, CTA optionnel |
| `SkeletonLoader` | Chargement | `type: 'card' \| 'text' \| 'avatar'`, `lines?` | — | Animation shimmer |
| `StatCounter` | Nombre animé | `value`, `label`, `suffix?` | animating, static | `prefers-reduced-motion` |
| `TestimonialCard` | Témoignage | `quote`, `author`, `role` | — | Italique, citation |
| `ToastNotification` | Toast | `type`, `message`, `duration?` | entering, visible, leaving | `aria-live="polite"` |
| `AlertBanner` | Alerte inline | `type`, `message`, `dismissible?` | visible, dismissed | Remplace les `alert()` |
| `WaveformVisualizer` | Waveform statique | `data[]`, `color`, `height` | — | Barres arrondies |
| `AppIcon` | Icône unifiée | `name`, `size`, `color` | — | Système d'icônes centralisé |

---

## 15. Recommandations Tailwind CSS

### Couleurs personnalisées
Le design system `arbor-*` est déjà bien défini. Suggestions d'amélioration :

```js
// tailwind.config.js — ajouts recommandés
colors: {
  arbor: {
    // existants conservés
    'glass-hover': 'rgba(255,255,255,0.06)',
    'fog': '#2a3142',
    'copper': '#B87333',
    // nouveaux
    'forest': '#1a2e1a',
    'mist': 'rgba(143, 166, 142, 0.1)',
  },
}
```

### Classes réutilisables

```css
/* Section de base */
.section {
  @apply py-16 sm:py-20 lg:py-24 section-padding;
}

/* Container premium */
.container-premium {
  @apply max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 xl:px-12;
}

/* Texte poétique */
.text-poetic {
  @apply font-display text-arbor-cream leading-relaxed;
}

/* Overlay gradient */
.overlay-gradient {
  @apply absolute inset-0 bg-gradient-to-t from-arbor-night via-transparent to-transparent pointer-events-none;
}

/* Glow subtil */
.glow-subtle {
  box-shadow: 0 0 40px rgba(52, 211, 153, 0.08);
}
```

### Spacing cohérent
Utiliser l'échelle Tailwind par défaut mais privilégier :
- `gap-4` (16px) pour les grilles denses
- `gap-6` (24px) pour les grilles standards
- `gap-8` (32px) pour les grises aérées
- `space-y-6` entre les sections d'un formulaire

### Responsive
- **Mobile-first** : base = mobile, breakpoints `sm:`, `md:`, `lg:`, `xl:`
- **Hero titre :** `text-4xl sm:text-5xl lg:text-6xl`
- **Section titre :** `text-2xl sm:text-3xl lg:text-4xl`
- **Cards grille :** `grid-cols-1 sm:grid-cols-2 lg:grid-cols-3`
- **Carte hauteur :** `h-[calc(100vh-4rem)]` desktop, `h-[calc(100dvh-4rem)]` mobile (dynamic viewport)

### Dark UI
- Le site est dark-only (`html class="dark"`). Pas besoin de classes `dark:`.
- S'assurer que toutes les couleurs sont suffisamment contrastées sur `#0B1220`.

### Hover / Focus
- **Hover :** Privilégier `transition-colors` ou `transition-transform`, jamais `transition-all` en production.
- **Focus :** `focus-visible:ring-2 focus-visible:ring-arbor-emerald focus-visible:ring-offset-2 focus-visible:ring-offset-arbor-night`
- **Active :** `active:scale-[0.98]` sur les boutons

### Transitions
```css
/* Standard */
.transition-standard {
  @apply transition-all duration-200 ease-out;
}

/* Smooth */
.transition-smooth {
  @apply transition-all duration-300 ease-in-out;
}

/* Bounce subtil */
.transition-bounce {
  @apply transition-transform duration-200;
  transition-timing-function: cubic-bezier(0.34, 1.56, 0.64, 1);
}
```

---

## 16. Exemples de textes UI améliorés

### Hero
- **Titre :** *"L'archive sonore du monde vivant"*
- **Sous-titre :** *"Explorez, écoutez et préservez les sons de la nature, capturés par une communauté de field recorders passionnés."*
- **CTA primaire :** *"Explorer la carte sonore"*
- **CTA secondaire :** *"Écouter les derniers sons"*

### Carte
- **Titre :** *"Carte sonore"*
- **Sous-titre :** *"Explorez les enregistrements à travers le monde"*
- **Placeholder recherche :** *"Rechercher un son, un lieu, un créateur..."*
- **État vide :** *"Ce territoire est encore silencieux. Soyez le premier à l'explorer."*
- **CTA état vide :** *"Publier un son ici"*

### Lecteur audio
- **Bouton play :** `aria-label="Lire [titre]"`
- **Bouton pause :** `aria-label="Mettre en pause"`
- **Temps :** Format `0:00` toujours
- **Album MediaSession :** *"Arborisis — Archive sonore"*

### Page ECHO
- **Titre :** *"Soutenez avec ECHO"*
- **Sous-titre :** *"Un geste simple pour remercier ceux qui capturent le monde vivant."*
- **Label conversion :** *"1 € = 10 ECHO"*
- **Répartition :** *"70 % créateur · 20 % infrastructure · 10 % communauté"*
- **Disclaimer :** *"ECHO n'est pas une cryptomonnaie. Ce n'est pas un investissement. C'est un soutien."*

### Communauté
- **Titre section :** *"Rejoignez la communauté"*
- **Sous-titre :** *"Créez votre profil, publiez vos premiers enregistrements et connectez-vous avec d'autres passionnés."*
- **CTA :** *"Créer un compte gratuit"* / *"J'ai déjà un compte"*

### États vides
- **Profil sans son :** *"Aucun son publié encore. Le silence n'est qu'un début."*
- **Liste sans résultat :** *"Aucun enregistrement ne correspond à votre recherche. Essayez d'élargir votre exploration."*
- **Activité vide :** *"Votre histoire commence ici. Publiez ou écoutez votre premier son."*

### Inscription
- **Titre :** *"Rejoindre l'archive"*
- **Sous-titre :** *"Créez votre profil en quelques secondes. Aucun engagement, juste l'écoute."*
- **CTA :** *"Créer mon profil"*
- **Lien secondaire :** *"Déjà membre ? Se connecter"*

### Publication d'un son
- **Titre :** *"Publier un son"*
- **Sous-titre :** *"Partagez un fragment du monde vivant."*
- **Upload :** *"Glissez votre fichier audio ici, ou cliquez pour parcourir"*
- **Géolocalisation :** *"Où avez-vous capturé ce moment ?"*
- **Bouton géoloc :** *"Utiliser ma position actuelle"* (avec état "Localisation en cours...")
- **CTA final :** *"Publier l'enregistrement"*

---

## 17. Plan d'action concret (7 jours)

### Jour 1 — Audit et corrections rapides
- [ ] Corriger tous les `alert()` natifs → `AlertBanner` ou toasts
- [ ] Corriger les contrastes (`text-arbor-sage` en dessous de `/70`)
- [ ] Ajouter `aria-label` sur les boutons icon-only critiques
- [ ] Désactiver `scrollWheelZoom` sur mobile pour Leaflet
- [ ] Clarifier la distinction entre les deux cartes (renommage ou labels)

### Jour 2 — Header, navigation et CTA
- [ ] Refondre `GuestLayout.vue` : navigation simplifiée (5 liens max)
- [ ] Refondre `AuthenticatedLayout.vue` : regrouper l'exploration dans un dropdown
- [ ] Implémenter le header shrink-on-scroll
- [ ] Hiérarchiser les CTAs sur la landing (primary / secondary / ghost)
- [ ] Ajouter le CTA sticky "Rejoindre" dans le menu mobile

### Jour 3 — Hero et landing page
- [ ] Ajouter la section "Démonstration audio" avec 6 `SoundCard` jouables
- [ ] Intégrer la carte en mode embed sous les sons
- [ ] Ajouter la section "Créateurs en avant"
- [ ] Ajouter la section "Comment ça marche" (3 étapes)
- [ ] Simplifier le footer (3 colonnes max)

### Jour 4 — Carte sonore
- [ ] Améliorer le design des pins (forme organique, halo)
- [ ] Améliorer les popups (glassmorphism, CTA clair)
- [ ] Optimiser la sidebar mobile (bottom-sheet)
- [ ] Ajouter les skeleton screens sur la carte
- [ ] Améliorer l'état vide (texte poétique + CTA)

### Jour 5 — Lecteur audio et cards
- [ ] Améliorer `MiniPlayer.vue` : ajouter waveform fine, réduire hauteur mobile
- [ ] Améliorer `Sounds/Show.vue` : layout plus immersif, waveform plus grande
- [ ] Créer le composant `SoundCard` réutilisable avec play overlay
- [ ] Créer le composant `CreatorCard`
- [ ] Harmoniser les radius et espacements des cards

### Jour 6 — Mobile et accessibilité
- [ ] Audit mobile complet (touch targets, tailles de texte, formulaires)
- [ ] Corriger les inputs : `aria-invalid`, `aria-describedby`
- [ ] Conditionner `animateCount` à `prefers-reduced-motion`
- [ ] Vérifier tous les `alt` des images
- [ ] Tester le clavier sur toutes les pages critiques

### Jour 7 — Polish premium, tests et finalisation
- [ ] Ajuster les animations (durées, easing)
- [ ] Réduire les particules sur la landing (6 max)
- [ ] Vérifier la cohérence du design system (pas de couleurs en dur)
- [ ] Review du copywriting (ton poétique, empty states)
- [ ] Tests utilisateurs rapides (3-5 personnes, tâches clés)
- [ ] Déployer en staging et valider

---

## 18. Checklist finale avant mise en production

### Desktop
- [ ] Header sticky fonctionnel, shrink au scroll
- [ ] Navigation claire (5 liens max guest)
- [ ] Hero impactant avec CTA hiérarchisés
- [ ] Carte interactive fluide (pins, popups, sidebar)
- [ ] Lecteur audio plein écran immersif
- [ ] Dashboard simplifié (pas d'overload)
- [ ] Toutes les pages ont un CTA clair

### Mobile
- [ ] Menu hamburger fonctionnel, slide-in fluide
- [ ] Hero lisible (titre ≤ 36px)
- [ ] Carte ne capture pas le scroll
- [ ] Mini-player compact (≤ 56px)
- [ ] Touch targets ≥ 44px partout
- [ ] Sidebar carte en bottom-sheet
- [ ] Pas de débordement horizontal

### Accessibilité
- [ ] Aucun `alert()` natif
- [ ] Tous les boutons icon-only ont `aria-label`
- [ ] Contraste WCAG AA validé (textes, boutons, liens)
- [ ] Focus visible sur tous les éléments interactifs
- [ ] Navigation clavier complète
- [ ] `prefers-reduced-motion` respecté
- [ ] Images informatives avec `alt` descriptif

### Performance
- [ ] Images below-fold avec `loading="lazy"`
- [ ] Skeleton screens sur les listes et la carte
- [ ] Pas de `transition-all` inutile
- [ ] Carte en lazy load (`defineAsyncComponent`)
- [ ] Polices préchargées (`preload`)

### SEO de base
- [ ] Titre de page unique par route
- [ ] Meta description sur toutes les pages publiques
- [ ] Images avec `alt` approprié
- [ ] URLs propres et descriptives
- [ ] Sitemap à jour

### Design
- [ ] Cohérence des couleurs (pas de hardcoded)
- [ ] Cohérence des radius (boutons 16px, cards 20px)
- [ ] Cohérence des espacements
- [ ] Ton poétique respecté partout
- [ ] Empty states engageants

### Conversion
- [ ] CTA "Explorer la carte" visible dès le hero
- [ ] Sons jouables sans inscription (landing)
- [ ] ECHO visible mais pas intrusif
- [ ] Inscription rapide et simple
- [ ] Preuve sociale présente (créateurs, stats)

### Bugs visuels
- [ ] Pas de débordement de texte
- [ ] Pas d'icônes cassées
- [ ] Pas de flash de contenu non stylisé
- [ ] Pas de z-index conflicts (modals au-dessus de tout)

### Tests utilisateurs (rapide)
- [ ] Nouvel utilisateur comprend Arborisis en 5 secondes
- [ ] Nouvel utilisateur écoute un son en moins de 3 clics
- [ ] Nouvel utilisateur trouve la carte en moins de 2 clics
- [ ] Créateur publie un son sans friction majeure
- [ ] Mobile : navigation intuitive sans frustration

---

## Annexes

### Références d'ambiance
- **Spotify** : Player plein écran, waveform, transitions fluides
- **Calm** : Minimalisme, tons naturels, pas d'agressivité
- **AllTrails** : Carte + exploration + fiches détaillées
- **Linear** : Glassmorphism subtil, dark UI raffiné, animations discrètes
- **Arc Browser** : Sidebar intelligente, typographie aérée

### Hypothèses
- **Hypothèse :** Le site en production correspond au code source exploré. Certaines fonctionnalités pourraient différer légèrement.
- **Hypothèse :** Les pages `/radio`, `/blog`, `/creators` existent mais n'ont pas été auditées en détail dans ce document. L'analyse se concentre sur les parcours critiques (landing → carte → son → profil).
- **Hypothèse :** La gamification (quêtes, XP, médailles) est optionnelle pour l'utilisateur lambda. Elle ne doit pas bloquer le parcours principal.

---

*Audit UI/UX stratégique réalisé le 2026-05-15. Complémentaire à l'audit technique frontend du 2026-05-14.*
