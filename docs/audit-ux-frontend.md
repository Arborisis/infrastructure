# Audit UX/UI — Frontend Arborisis

**Date :** 2026-05-14  
**Scope :** `arborisis/resources/js/**`, `arborisis/resources/css/**`, `arborisis/resources/views/**`  
**Stack :** Vue 3 (Composition API) + Inertia.js + Tailwind CSS + Pinia  
**Référentiel :** UI/UX Pro Max (accessibilité, animation, layout, dark-mode, vue-tailwind)

---

## 1. Executive Summary & Scorecard

| Pilier | Score /10 | Status |
|--------|-----------|--------|
| Design System & Cohérence | **7.5** | Bon, mais fragmentation visuelle mineure |
| Accessibilité (a11y) | **5.5** | ⚠️ Problèmes de contraste, z-index, alerts brutes |
| Navigation & Architecture | **7.0** | Double carte source de confusion, menus OK |
| Formulaires & Interactions | **6.5** | Labels OK, mais feedback géoloc brutal, pas de loading states |
| Performance perçue | **7.0** | Lazy loading partiel, skeletons absents |
| Mobile & Responsive | **6.5** | Touch targets OK, mais sidebar carte mobile perfectible |
| Motion & Animation | **7.0** | Réduit-motion géré, mais particules excessives sur Landing |
| Contenu & Microcopy | **8.0** | Ton cohérent, empty states engageants |
| **Moyenne globale** | **6.9 / 10** | **Solide mais des blockers a11y à corriger** |

---

## 2. Accessibilité (A11y) — CRITICAL

### 2.1 Contrastes de couleur insuffisants
**Problème :** Plusieurs textes utilisent `text-arbor-sage` avec opacité réduite (`/50`, `/60`, `/70`) sur fond sombre. La couleur `#8FA68E` (arbor-sage) sur `#0B1220` (arbor-night) donne un ratio de ~4.6:1, ce qui passe à peine le seuil WCAG AA pour du texte normal. Avec une opacité de 50 %, le ratio tombe en dessous de 2.5:1.

**Localisations :**
- `Landing.vue:172` : `text-arbor-sage` dans le hero (OK, mais vérifiez `/50` et `/60`)
- `Map/Index.vue:231` : `placeholder:text-arbor-sage/40`
- `Sounds/Create.vue:135` : `text-xs text-arbor-sage/60`
- `Profile/Show.vue:73` : `text-arbor-sage/70` pour la localisation/website
- `Dashboard.vue` (multiple) : stat labels en `text-arbor-sage`

**Recommandation P1 :**
- Ne jamais descendre en dessous de `text-arbor-sage/70` pour du texte lisible.
- Pour les placeholders, utiliser `text-arbor-sage/60` minimum.
- Vérifier avec un outil comme WebAIM Contrast Checker avant livraison.

### 2.2 `alert()` brutes — blocage de l'expérience
**Problème :** Utilisation de `alert()` natif pour les erreurs utilisateur. Cela bloque le thread UI, n'est pas stylisable, et est considéré comme un anti-pattern UX moderne.

**Localisations :**
- `ArborisisMap/Index.vue:287,289,294,334,336,338,340,342,346` — 9 occurrences
- `Sounds/Create.vue:85` — géolocalisation échouée

**Recommandation P0 :**
Remplacer par un toast/notification inline ou un composant `AlertBanner` stylisé.

```vue
<!-- AVANT (Sounds/Create.vue:85) -->
alert('Impossible d\'obtenir votre position.');

<!-- APRÈS -->
const geoError = ref('');
// dans le template :
<div v-if="geoError" class="mt-2 text-sm text-red-400 flex items-center gap-1.5">
  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
  </svg>
  {{ geoError }}
</div>
// dans le catch :
geoError.value = 'Impossible d\'obtenir votre position. Vérifiez les permissions de votre navigateur.';
```

### 2.3 Z-index arbitraires et gestion du stacking context
**Problème :** Des valeurs comme `z-[1000]`, `z-[800]`, `z-[70]`, `z-[65]` créent une guerre de z-index difficile à maintenir.

**Localisations :**
- `Layouts/AuthenticatedLayout.vue:17` : `z-[1000]` (nav)
- `Layouts/GuestLayout.vue:20` : `z-[1000]` (nav)
- `ArborisisMap/Index.vue:479,489,540` : `z-[800]`
- `CookieBanner.vue:36` : `z-[100]`
- `OfflineBanner.vue:20` : `z-[65]`
- `PwaUpdatePrompt.vue:29` : `z-[70]`
- `PwaInstallPrompt.vue:40` : `z-[60]`

**Recommandation P1 :**
Définir une échelle sémantique dans `tailwind.config.js` :
```js
zIndex: {
  'base': '0',
  'dropdown': '10',
  'sticky': '20',
  'fixed-nav': '30',
  'drawer': '40',
  'modal': '50',
  'popover': '60',
  'toast': '70',
  'tooltip': '80',
  'banner': '90',
  'max': '100',
}
```

### 2.4 `aria-label` manquants sur les boutons icon-only
**Problème :** Seulement 14 occurrences de `aria-label` dans tout le frontend. Beaucoup de boutons SVG-only n'ont pas de nom accessible.

**Exemples :**
- `Dashboard.vue` — boutons play/pause sur les sound cards (overlay)
- `Sounds/Show.vue:166` — bouton play principal (OK, car il a un label visuel adjacent, mais pas explicite)
- `Map/Index.vue:235` — bouton clear search (OK, a `aria-label`)
- `Radio/Index.vue:211` — boutons de changement de visualizer (pas de `aria-label`)

**Recommandation P1 :**
Tout bouton ne contenant que du SVG doit avoir `aria-label`.

### 2.5 Images décoratives vs informatives — `alt` ambigu
**Problème :** Plusieurs images informatives ont `alt=""` (vide), ce qui les rend invisible aux lecteurs d'écran.

**Localisations :**
- `Radio/Index.vue:346` : `nextUp.cover_url` — `alt=""` (devrait être `alt=""` si purement décoratif, mais ici c'est un contenu informatif → `alt=""` est acceptable si le titre est déjà annoncé)
- `Radio/Index.vue:375` : historique cover — `alt=""` (même cas)
- `Landing.vue:116` : hero image — `alt=""` (correct, image de fond décorative)
- `Admin/RadioManager.vue:235` : `alt=""` (à vérifier)

**Recommandation P2 :** Documenter la convention : `alt=""` pour décoratif, descriptif pour informatif.

---

## 3. Design System & Cohérence Visuelle

### 3.1 Cohérence des composants de base
**Points positifs :**
- Système de tokens `arbor-*` bien défini dans `tailwind.config.js`.
- Composants réutilisables : `PrimaryButton`, `TextInput`, `Checkbox`, `Modal`.
- `glass-card`, `btn-primary`, `btn-secondary` etc. définis dans `app.css` avec `@layer components`.

**Problèmes :**
- **Fragmentation des inputs :** `TextInput.vue` utilise `rounded-xl`, mais `Sounds/Create.vue` utilise `rounded-lg` sur certains champs natifs (`select`, `textarea`).
- **TextInput.vue n'a pas de prop `type` par défaut** — il reçoit `type="email"`, `type="password"` via les attrs, mais le composant de base ne les expose pas explicitement.
- **Checkbox.vue** n'a pas de `aria-label` ni de slot pour un label textuel. Dans `Sounds/Create.vue:231`, le label est un `<label for="...">` séparé — OK, mais fragile si l'ID change.

### 3.2 Typographie
**Points positifs :**
- Bonne hiérarchie : `font-display` (Cormorant) pour les titres, `font-sans` (DM Sans) pour le corps.
- `font-mono` (JetBrains Mono) pour les données chiffrées (durées, stats).

**Problème :**
- `font-serif` utilisé ponctuellement (`PwaInstallPrompt.vue:48`) sans être défini dans le theme Tailwind. Cela tombe sur la police par défaut du navigateur (Times New Roman), ce qui crée une incohérence.

**Recommandation P1 :**
```css
/* tailwind.config.js */
fontFamily: {
  serif: ['Cormorant', 'Georgia', 'serif'], // ou supprimer font-serif
}
```

### 3.3 Couleurs et tokens
**Problème :**
- `bg-[#111827]` utilisé en dur dans `Login.vue:209` et `Register.vue:209` au lieu du token `bg-arbor-deep`.
- `border-white/10` et `bg-white/5` utilisés dans `CreateArborisisPointForm.vue` — incohérent avec le design system `arbor-glass`, `arbor-glass-border`.

---

## 4. Navigation & Architecture de l'Information

### 4.1 Double carte = confusion cognitive
**Problème majeur :** Deux routes distinctes proposent une carte :
- `/map` — Carte sonore (tous les enregistrements)
- `/arborisis-map` — Carte Arborisis (gamification, points d'intérêt)

Les deux sont dans la navigation principale (`Explorer` dropdown). Les noms sont similaires et l'icône aussi (pin/map). Un utilisateur non averti ne comprendra pas la différence.

**Recommandation P0 :**
- Renommer explicitement : `Carte des sons` vs `Carte de communauté (visites)`.
- Ou fusionner les deux cartes en une seule avec un toggle de couche.

### 4.2 Wayfinding sur les pages profondes
**Problème :** Pas de fil d'Ariane (breadcrumb). Sur `Sounds/Show.vue`, il y a un bouton "Retour aux sons", mais sur `Profile/Show.vue` d'un créateur, il n'y a pas de retour vers la liste.

**Recommandation P2 :**
Ajouter un composant `Breadcrumb` sur les pages profondes (`Sounds/Show`, `Profile/Show`, `Chat/Room`).

### 4.3 Menu mobile
**Points positifs :**
- Hamburger avec `aria-label` et `aria-expanded` dynamique.
- Menu responsive bien structuré dans les deux layouts.

**Problème :**
- Le menu mobile du `GuestLayout` n'a pas d'état `aria-expanded` sur les liens de sous-menu (il n'y en a pas, mais le dropdown "Explorer" du `AuthenticatedLayout` n'existe pas en mobile — les liens sont plats).

---

## 5. Formulaires & Interactions

### 5.1 Upload de son — bonnes pratiques
**Points positifs :**
- Drag & drop avec feedback visuel (`isDragging`).
- Preview audio après sélection.
- Bouton de suppression clair.

**Problème :**
- Pas d'indicateur de progression d'upload (`form.processing` affiche juste "Publication en cours..."). Pour des fichiers audio de 500 Mo, un utilisateur peut croire que rien ne se passe.

**Recommandation P1 :**
Ajouter une barre de progression d'upload (Inertia supporte `onProgress`) :
```js
const submit = () => {
    form.post(route('sounds.store'), {
        forceFormData: true,
        onProgress: (progress) => {
            uploadProgress.value = progress.percentage;
        },
        // ...
    });
};
```

### 5.2 Géolocalisation — UX brutale
**Problème :** Le bouton "Utiliser ma position actuelle" (`Sounds/Create.vue:207`) :
1. N'a pas d'état de chargement (spinner).
2. Utilise `alert()` en cas d'erreur.
3. Ne demande pas de confirmation avant de remplacer les champs existants.

**Recommandation P1 :**
```vue
<button
  type="button"
  @click="getCurrentLocation"
  :disabled="locating"
  class="..."
>
  <svg v-if="locating" class="animate-spin w-4 h-4" ... />
  <span v-if="locating">Localisation...</span>
  <span v-else>Utiliser ma position actuelle</span>
</button>
```

### 5.3 Validation et erreurs
**Points positifs :**
- `InputError` utilisé systématiquement.
- `InputLabel` avec `for` attribute.
- État `disabled` sur les boutons de soumission.

**Problème :**
- `TextInput.vue` n'annonce pas les erreurs aux lecteurs d'écran. Il faudrait `aria-invalid` et `aria-describedby`.

**Recommandation P1 :**
```vue
<!-- TextInput.vue -->
<input
  :aria-invalid="!!$attrs['aria-error']"
  :aria-describedby="$attrs['aria-describedby']"
  class="..."
/>
```

---

## 6. Performance Perçue & États de Chargement

### 6.1 Skeleton screens
**Problème :** Aucun skeleton screen n'est utilisé. Les états de chargement se limitent à des spinners (`animate-spin`) ou du texte "Chargement...".

**Localisations manquantes :**
- `Map/Index.vue` — sidebar liste de sons
- `Dashboard.vue` — stats, recent sounds, activités
- `Creators/Index.vue` — grille de créateurs
- `Landing.vue` — carte preview

**Recommandation P2 :**
Utiliser le style `.skeleton` déjà défini dans `app.css` :
```vue
<div class="h-4 bg-arbor-charcoal rounded skeleton w-3/4" />
```

### 6.2 Lazy loading
**Points positifs :**
- `loading="lazy"` sur les images des cartes (`Map/Index.vue:321`).
- `defineAsyncComponent` pour `SoundMap` dans `Landing.vue`.

**Problème :**
- Les avatars dans `Creators/Index.vue:84` n'ont pas `loading="lazy"`.
- Les covers dans `Profile/Show.vue:151` (grid) n'ont pas `loading="lazy"`.

---

## 7. Mobile & Responsive

### 7.1 Touch targets
**Points positifs :**
- La plupart des boutons respectent 44×44px.
- `Mobile sidebar toggle` dans `Map/Index.vue:188` fait 48×48px.

**Problème :**
- `Map/Index.vue:235` — bouton clear search (16×16px visuel, mais la zone cliquable est probablement trop petite si le padding est insuffisant).
- Les boutons de catégorie dans la sidebar (`px-3 py-1.5`) peuvent être juste en dessous de 44px en hauteur.

### 7.2 Carte interactive sur mobile
**Problème :** Sur mobile, la carte Leaflet capture les gestures de scroll. Si l'utilisateur fait défiler la page pour atteindre le footer, il peut se retrouver "bloqué" dans la carte.

**Recommandation P1 :**
Désactiver le scroll de la carte sur mobile jusqu'à ce que l'utilisateur tapote explicitement :
```js
// dans SoundMap.vue ou ArborisisMap
L.map(container, {
  scrollWheelZoom: window.innerWidth >= 768,
  dragging: true,
});
```

### 7.3 MiniPlayer sur mobile
**Problème :** Le mini-player (`MiniPlayer.vue`) occupe `bottom-0` avec `z-50`. Sur mobile, s'il y a aussi la bannière cookie (`z-[100]`) et le prompt PWA (`z-[60]`), l'écran peut devenir très encombré.

**Recommandation P2 :**
- Réduire la hauteur du mini-player sur mobile (< 640px).
- Fermer automatiquement le prompt PWA si le mini-player est actif.

---

## 8. Motion, Animation & Micro-interactions

### 8.1 `prefers-reduced-motion`
**Points positifs :**
- `app.css` contient déjà :
```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

**Problème :**
- Les animations JS (`animateCount` dans `Dashboard.vue` et `Landing.vue`) ne sont pas conditionnées par `prefers-reduced-motion`.
- `Landing.vue:143` — 12 particules animées en `animate-pulse-slow`. Sur un écran de réduction de mouvement, cela reste actif (CSS gère, mais les particules générées en JS restent dans le DOM).

### 8.2 Durées des transitions
**Points positifs :**
- La plupart des transitions sont entre 200ms et 300ms.
- `Login.vue` et `Register.vue` ont des cascades d'animation bien orchestrées.

**Problème :**
- `app.css` : `.btn-primary` utilise `transition-all duration-300`. `transition-all` est plus coûteux que `transition-colors`.
- `Dashboard.vue` : `hover:scale-110` sur les icônes de stat cards peut causer du layout shift si l'élément n'est pas isolé.

### 8.3 Animations infinies
**Problème :**
- `Landing.vue:143` — particules avec `animation: pulse 4s cubic-bezier(0.4, 0, 0.6, 1) infinite`.
- `SoundMap.vue:309` — `animate-ping` sur l'empty state.
- `PlayerProgressCard.vue:60` — `animate-[shimmer_2s_ease-in-out_infinite]` sur la barre XP.

**Recommandation P2 :**
Limiter les animations infinies aux indicateurs de chargement. Pour les particules décoratives, réduire le nombre à 6 maximum.

---

## 9. Contenu & Microcopy

### 9.1 Ton de voix
**Excellent.** Le ton est poétique, respectueux de la nature, et cohérent avec la charte éditoriale d'Arborisis. Exemples :
- "L'archive sonore de la nature"
- "Découvrez, partagez et préservez les sons du monde vivant"
- "Continuez l'exploration" (gamification)

### 9.2 Empty states
**Points positifs :**
- `Profile/Show.vue:199` : "Aucun son publié" + icône + contexte
- `Map/Index.vue:357` : "Aucun enregistrement ici" + CTA réinitialiser
- `Dashboard.vue:447` : "Aucun enregistrement" + bouton publier

**Problème :**
- `Chat/Index.vue` (non lu en détail) — vérifier que les empty states de chat ont un CTA clair.

### 9.3 Copy ECHO
**Point positif :**
- "Pas une cryptomonnaie. Pas un investissement." (`Landing.vue:321`) — clair et conforme à AGENTS.md.

---

## 10. Patterns Anti-UX & Risques Identifiés

### 10.1 Synchronisation audio double lecteur
**Risque :** `MiniPlayer.vue` (global) et `Sounds/Show.vue` (page) partagent le même `usePlayerStore`, mais `WaveSurfer` dans `Sounds/Show.vue` a sa propre instance. Les états peuvent se désynchroniser si l'utilisateur interagit avec les deux en parallèle.

**Recommandation P1 :**
S'assurer que `WaveSurfer` écoute les changements de `playerStore.currentTime` et inversement.

### 10.2 Gamification — densité informationnelle
**Risque :** Le `Dashboard.vue` affiche stats, gamification, quêtes, activités, ECHO, actions rapides, achievements. Sur un écran 13", c'est beaucoup d'informations simultanées.

**Recommandation P2 :**
- Utiliser des accordéons (collapsible sections) pour les quêtes et l'activité récente.
- Ou déplacer la gamification dans un onglet dédié.

### 10.3 Cookie Banner
**Point positif :** Excellente implémentation. Consent Mode v2, préférences détaillées, toggle analytics/publicité, boutons "Tout refuser" / "Tout accepter" / "Personnaliser". ARIA roles corrects.

---

## 11. Plan d'Action Priorisé

### P0 — Corriger immédiatement (blockers a11y & UX)
| # | Action | Fichier(s) |
|---|--------|-----------|
| 1 | Remplacer tous les `alert()` par des toasts inline | `ArborisisMap/Index.vue`, `Sounds/Create.vue` |
| 2 | Ajouter `aria-label` aux boutons icon-only manquants | `Radio/Index.vue`, `Dashboard.vue`, `Sounds/Show.vue` |
| 3 | Clarifier la distinction entre les deux cartes | Navigation, Landing, labels |
| 4 | Ajouter `scrollWheelZoom: false` sur mobile pour Leaflet | `SoundMap.vue`, `ArborisisMap/Index.vue` |

### P1 — Améliorer (impact UX significatif)
| # | Action | Fichier(s) |
|---|--------|-----------|
| 5 | Ajouter un état de chargement au bouton géolocalisation | `Sounds/Create.vue` |
| 6 | Augmenter la taille des touch targets < 44px | Sidebar catégories, clear search |
| 7 | Ajouter `loading="lazy"` sur les images manquantes | `Creators/Index.vue`, `Profile/Show.vue` |
| 8 | Harmoniser les radius des inputs | Tous les formulaires |
| 9 | Implémenter une barre de progression d'upload | `Sounds/Create.vue` |
| 10 | Créer une échelle de z-index sémantique | `tailwind.config.js` |
| 11 | Ajouter `aria-invalid` / `aria-describedby` aux inputs | `TextInput.vue`, formulaires |

### P2 — Polir (qualité perçue)
| # | Action | Fichier(s) |
|---|--------|-----------|
| 12 | Ajouter des skeleton screens | `Dashboard.vue`, `Map/Index.vue` |
| 13 | Réduire le nombre de particules sur Landing | `Landing.vue` |
| 14 | Ajouter un fil d'Ariane | `Sounds/Show.vue`, `Profile/Show.vue` |
| 15 | Conditionner `animateCount` à `prefers-reduced-motion` | `Landing.vue`, `Dashboard.vue` |
| 16 | Supprimer `font-serif` non défini | `PwaInstallPrompt.vue` |

---

## 12. Checklist Pré-Délivrance Personnalisée

Avant chaque mise en production du frontend Arborisis, vérifier :

- [ ] **A11y :** Aucun `alert()` natif dans le code
- [ ] **A11y :** Tous les boutons icon-only ont `aria-label`
- [ ] **A11y :** Les contrastes des textes `text-arbor-sage/*` passent le ratio 4.5:1
- [ ] **A11y :** `aria-invalid` et `aria-describedby` présents sur les champs en erreur
- [ ] **Responsive :** Test mobile sur la carte (pas de scroll capturé par Leaflet)
- [ ] **Responsive :** Touch targets ≥ 44×44px sur tous les éléments interactifs
- [ ] **Performance :** Images below-fold avec `loading="lazy"`
- [ ] **Performance :** Pas de `transition-all` inutile (privilégier `transition-colors`)
- [ ] **Motion :** `prefers-reduced-motion` respecté pour les animations JS
- [ ] **Design System :** Pas de couleurs en dur (`#111827`, `white/10`)
- [ ] **Copy :** Empty states avec CTA clair et ton poétique respecté
- [ ] **Navigation :** Fil d'Ariane ou bouton retour sur les pages profondes

---

## 13. Conclusion

Le frontend Arborisis est **visuellement cohérent et esthétiquement réussi**. Le design system sombre avec accents verts et ambrés fonctionne bien pour l'identité "nature". Cependant, plusieurs **blockers d'accessibilité** doivent être corrigés avant d'être considéré comme production-ready pour un public large :

1. **Les `alert()` brutes** sont le problème le plus urgent.
2. **La gestion du z-index** et des contrastes faibles suit de près.
3. **La double carte** crée une confusion cognitive qu'il faut résoudre par un renommage ou une fusion.

Les fondations sont solides. Avec les corrections P0 et P1, le projet peut atteindre un score d'environ **8.5/10**.

---

*Audit réalisé par Kimi Code CLI — Référentiel UI/UX Pro Max v1.0*
