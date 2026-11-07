# IA.md — Instructions de travail & suivi du projet

> **Fichier de pilotage du projet.** À lire en premier à chaque session, avant `LORE.md` et avant tout code.
> Ce fichier contient : (1) les instructions permanentes avec lesquelles je dois procéder, (2) l'avancement du projet, mis à jour au fil des discussions.

---

## 1. Identité du projet

- **Nom du jeu :** Five Nights at Guillaume Alves
- **Nom de la repo :** `Cinqo-noches-at-Guillaumes-Alves`
- **Genre :** Fangame FNaF (Five Nights at Freddy's)
- **Ton :** Totalement absurde / drôle, **mais horrifique aussi**. Les deux en même temps, sans que l'un annule l'autre.
  - L'humour doit être absurde, décalé, parfois gênant.
  - L'horreur doit rester réelle : tension, jumpscares, malaise, lore sombre sous la surface absurde.
  - Ne jamais "adoucire" le jeu pour le rendre juste drôle, ni le rendre juste sérieux.
- **Moteur :** Godot 4.6, renderer GL Compatibility (voir `project.godot`)
- **Physique 3D :** Jolt Physics
- **État actuel de la repo (au 2026-11-06, fin de journée) :** **base de jeu FNaF jouable** : menu branché, 5 nuits, bureau scrollable, portes/lumières/énergie, 11 caméras, IA des 4 esprits, jumpscares, game over, victoire de nuit, fin provisoire, sauvegarde navigateur. Tous les visuels sont des formes géométriques temporaires remplaçables par images (`assets/renders/README.md`). Historique : projet Godot squelette + **première scène 2D : le menu d'accueil** (`scenes/main_menu.tscn` + `scripts/main_menu.gd`, scène principale définie dans `project.godot`). Écran noir, titre en haut, boutons "New Game" / "Continue" / "Settings" en bas à gauche, avec préfixe `>> ` au survol (style FNaF). Les boutons ne font rien pour l'instant (aucune autre scène). La **police VHS VT323** (OFL) est intégrée : fichier `fonts/VT323-Regular.ttf` + `Theme` partagé `themes/main_theme.tres` assigné au menu. **Export web automatisé** via GitHub Actions (`.github/workflows/deploy_web.yml`) : build Godot 4.6.3 sans threads et déploiement sur GitHub Pages à chaque push sur `main`. Aucun asset de jeu pour l'instant — les rendus 3D des scènes et personnages seront créés plus tard par Guillaume.

## 2. Instructions permanentes — comment je dois procéder

### 2.1 Communication avec Guillaume
- Répondre en **français** (langue de Guillaume dans ce projet), sauf demande contraire.
- Être direct, concret, sans blabla inutile. Pas de compliments creux.
- Quand Guillaume raconte du lore / du gameplay : **noter en détail dans `LORE.md`**, ne pas faire le minimum. Développer, structurer, relier les éléments entre eux, mais **ne pas inventer du canon à sa place** : ce qui n'est pas dit par lui est marqué `À compléter` ou `Piste à valider`, jamais présenté comme décidé.
- Quand une information est ambiguë ou contradictoire, le signaler et demander clarification plutôt que trancher seul.
- Proposer des idées séparément du canon, dans une section clairement étiquetée `Pistes / idées à valider`.

### 2.2 Fichiers de référence
- **`IA.md` (ce fichier)** : instructions + avancement. Mis à jour à chaque étape importante.
- **`LORE.md`** : tout le lore, l'histoire et le gameplay racontés par Guillaume. C'est la source de vérité du jeu. En cas de conflit entre une idée dans le code et `LORE.md`, `LORE.md` gagne (sauf si Guillaume demande un changement).
- **`README.md`** : description publique courte. Ne pas y mettre de lore détaillé.

### 2.3 Règles de développement
- Ne pas ajouter de fonctionnalités, de refactorings ou d'abstractions au-delà de ce qui est demandé.
- Avant d'écrire du code : relire `IA.md` + `LORE.md`, et les fichiers concernés.
- Respecter les conventions Godot 4.6 : GDScript, scènes `.tscn`, nœuds, signaux, `res://`.
- Tout nouveau système de jeu (animatronic, caméra, porte, énergie, nuit...) doit d'abord être décrit dans `LORE.md` (gameplay), puis implémenté, puis noté dans la section Avancement ci-dessous.
- Ne jamais décrire un travail comme terminé s'il ne l'est pas. Dire exactement ce qui reste à faire.
- Garder les commits / changements petits et cohérents avec l'étape en cours.

### 2.4 Mise à jour de ce fichier
- Après chaque session de travail : ajouter une entrée dans **§4 Journal d'avancement** (date, ce qui a été fait, ce qui a été décidé, ce qui reste).
- Après chaque décision de Guillaume (lore, gameplay, nom, mécanique...) : la reporter dans `LORE.md` **et** la résumer dans le journal.
- Si une instruction permanente change : modifier §2 et noter le changement dans le journal.

## 3. Structure prévue du jeu (à compléter avec Guillaume)

> Section de planification — pas encore du canon tant que Guillaume ne l'a pas validé dans `LORE.md`.

- [x] Boucle de jeu de base : FNaF classique, 5 nuits (confirmé), 12 AM → 6 AM — fonctionnalités spéciales par personnage encore à définir
- [x] Bureau du joueur : scroll horizontal, portes, lumières, énergie (`scripts/game/office.gd`)
- [x] Système de caméras : 11 caméras, carte, neige, brouillage (plan provisoire FNaF 1)
- [x] Sauvegarde de la progression dans le navigateur (`scripts/autoload/save_manager.gd`, `user://save.cfg` → IndexedDB sur le web)
- [x] Visuels remplaçables : `RenderSlot` + `assets/renders/` (formes temporaires dans `scripts/visuals/placeholders.gd`)
- [ ] Les 4 personnages : Super Clovis (Bonnie, le plus agressif, en premier), White Paul-Henri (Chica, "l'entre deux" = pas trop agressif mais pas super chill), Joey Joestar (Foxy), Guillaume Alves (Freddy, nuit 5 uniquement, homme mort dans le costume de l'ours Alves) — comportements, IA par nuit, mécaniques spéciales à définir. Les 3 premiers sont activés en même temps dès le début, mais tous n'arrivent pas au bureau la première nuit (certains plus lents)
- [ ] Mécaniques de défense / survie (portes, lumière, bruit, énergie...)
- [x] Jumpscares et game over (version simple, image fixe zoomée)
- [ ] Nuits, progression, difficulté
- [ ] Fin / secret / easter eggs
- [ ] Audio : ambiances, bruits, musique
- [x] Interface : menu d'accueil (écran noir, titre, boutons "New Game" / "Continue" / "Settings" avec `>> ` au survol — boutons inactifs pour l'instant)
- [x] Interface : police VHS pour les textes de menu — **VT323** (Google Fonts, licence OFL) déposée dans `fonts/VT323-Regular.ttf`, intégrée via le `Theme` partagé `themes/main_theme.tres` (police par défaut + couleurs gris clair / blanc au survol) assigné au menu
- [x] Export web + déploiement GitHub Pages automatisés (`.github/workflows/deploy_web.yml` : Godot 4.6.3, export **sans threads** pour être compatible Pages)
- [x] Interface : écran « 12:00 AM / Night N », écran de game over, écran « 6 AM », écran de fin provisoire

## 4. Journal d'avancement

### 2026-11-05 — Création des fichiers de pilotage
- **Fait :**
  - Lecture complète de la repo : projet Godot 4.6 squelette, aucun code/scène/asset.
  - Création de `IA.md` (ce fichier) : instructions permanentes + suivi.
  - Création de `LORE.md` : structure détaillée du lore/gameplay, en attente de la narration de Guillaume.
- **Décidé :**
  - Thème du jeu : fangame FNaF absurde/drôle **et** horrifique.
  - `LORE.md` = source de vérité ; `IA.md` = instructions + avancement.
- **Reste à faire :**
  - Guillaume raconte l'histoire et le gameplay → remplissage détaillé de `LORE.md`.
  - Définir la structure des nuits, les animatronics et les mécaniques.
  - Créer la première scène / le premier prototype jouable.

### 2026-11-05 — Gameplay de base & les 4 esprits
- **Fait :**
  - `LORE.md` mis à jour en détail : §1.1 (esprits de morts, gameplay FNaF classique + spéciales par personnage), §2.3 renommé "Les personnages principaux — les esprits" avec tableau de correspondance FNaF et fiches pour les 4 personnages, §3.1 / §3.5 / §3.6 / §3.7 mis à jour, historique §7 complété.
  - `IA.md` §3 mis à jour avec les 4 personnages et leurs équivalences.
- **Décidé (canon, par Guillaume) :**
  - Gameplay : FNaF classique en base ; fonctionnalités spéciales définies en fonction des personnages.
  - Les personnages principaux ne sont **pas des animatronics** mais des **esprits de morts pour la plupart**.
  - **Super Clovis** = équivalent de Bonnie, le plus agressif, apparaît en premier.
  - **White Paul-Henri** = équivalent de Chica, "l'entre deux".
  - **Joey Joestar** = équivalent de Foxy.
  - **Guillaume Alves** = équivalent de Freddy, n'arrive **qu'à la nuit 5**.
- **Reste à faire :**
  - Préciser pour chaque esprit : apparence, personnalité, origine/mort, mécanique spéciale, jumpscare, nuits d'activation.
  - Clarifier "l'entre deux" de White Paul-Henri et le "pour la plupart" (qui n'est pas un esprit de mort ?).
  - Continuer la narration du lore (établissement, histoire, autres personnages) et du gameplay (bureau, caméras, survie, nuits).

### 2026-11-05 — Précisions : "l'entre deux", Guillaume en costume, activation simultanée
- **Fait :**
  - `LORE.md` mis à jour : §1.1, §2.2 (Guillaume Alves : homme mort, esprit dans le costume de l'ours Alves), §2.3 (tableau + fiches White Paul-Henri et Guillaume Alves), §3.5 (activation), §3.6 (nuit 1), historique §7.
- **Décidé (canon, par Guillaume) :**
  - **"L'entre deux"** de White Paul-Henri = pas trop agressif, mais pas super chill non plus (agressivité intermédiaire).
  - **Guillaume Alves n'est pas un esprit de mort comme les autres** : c'est un homme nommé Guillaume, mort, dont l'esprit est allé dans le costume de l'ours Alves. C'est lui le "pour la plupart".
  - **Activation :** Super Clovis, White Paul-Henri et Joey Joestar sont **tous activés en même temps** dès le début, mais **tous n'arrivent pas au bureau la première nuit** (certains sont plus lents). Guillaume Alves n'arrive qu'à la nuit 5.
- **Reste à faire :**
  - Guillaume va raconter le lore complet de Guillaume Alves ("ça sera long à dire") → à noter en détail dans `LORE.md` §2.2 / §2.3 quand il le racontera.
  - Préciser pour chaque personnage : apparence, personnalité, origine/mort, mécanique spéciale, jumpscare, vitesse / lenteur par nuit.
  - Continuer la narration du lore (établissement, autres personnages) et du gameplay (bureau, caméras, survie, nuits).

### 2026-11-05 — Première scène 2D : le menu d'accueil
- **Fait :**
  - Création de `scenes/main_menu.tscn` : écran noir (`ColorRect`), titre "Five Nights at Guillaume Alves" en haut (centré), et en bas à gauche un `VBoxContainer` avec les boutons "New Game", "Continue", "Settings" (alignés à gauche).
  - Création de `scripts/main_menu.gd` : au survol de la souris sur un bouton, un préfixe `>> ` apparaît devant le texte (comme dans le vrai FNaF) et disparaît quand la souris quitte le bouton. Les boutons ne font rien pour l'instant (aucune autre scène).
  - `project.godot` : scène principale définie (`run/main_scene="res://scenes/main_menu.tscn"`).
- **Décidé (par Guillaume) :**
  - Première scène = menu d'accueil. Pour l'instant : écran noir + titre en haut + boutons en bas à gauche. Les rendus 3D des scènes et personnages seront créés plus tard par Guillaume — ne pas créer d'assets 3D pour l'instant.
  - Le `>> ` au survol est une signature du menu (style FNaF) à conserver.
- **Reste à faire :**
  - Brancher les boutons quand les autres scènes existeront (New Game → première nuit, Continue → reprise, Settings → réglages).
  - Guillaume va raconter le lore complet de Guillaume Alves ("ça sera long à dire") → à noter en détail dans `LORE.md` §2.2 / §2.3.
  - Préciser pour chaque personnage : apparence, personnalité, origine/mort, mécanique spéciale, jumpscare, vitesse / lenteur par nuit.
  - Continuer la narration du lore (établissement, autres personnages) et du gameplay (bureau, caméras, survie, nuits).

### 2026-11-05 — Police VHS pour les menus
- **Fait :**
  - Style VHS appliqué dans `scenes/main_menu.tscn` : titre et boutons en gris clair (`Color(0.85, 0.85, 0.85)`) sur fond noir, texte des boutons en blanc pur au survol (`font_hover_color`).
  - Création de `fonts/README.md` : procédure pour déposer le fichier de police (VCR OSD Mono de Riciery Leal, gratuite, ou VT323 en OFL) et l'assigner au titre et aux boutons dans l'éditeur.
- **Décidé (par Guillaume) :**
  - Les écritures de menu doivent utiliser une police style VHS.
  - La repo sera rendue **publique** (GitHub Pages gratuit pour les dépôts publics) — Guillaume s'en charge.
- **Reste à faire :**
  - Guillaume dépose le `.ttf` dans `fonts/` et l'assigne dans `scenes/main_menu.tscn` (ou via un `Theme` partagé `themes/main_theme.tres`).
  - Guillaume rend la repo publique, active GitHub Pages (source : GitHub Actions) et pousse les fichiers pour déclencher le premier export web automatique.
  - Guillaume va raconter le lore complet de Guillaume Alves ("ça sera long à dire") → à noter en détail dans `LORE.md` §2.2 / §2.3.
  - Préciser pour chaque personnage : apparence, personnalité, origine/mort, mécanique spéciale, jumpscare, vitesse / lenteur par nuit.
  - Continuer la narration du lore (établissement, autres personnages) et du gameplay (bureau, caméras, survie, nuits).

### 2026-11-06 — Police VHS intégrée + export web automatisé vers GitHub Pages
- **Fait :**
  - **Police VHS intégrée :** ajout de `fonts/VT323-Regular.ttf` (Google Fonts, licence OFL — sans ambiguïté de licence) et création du `Theme` partagé `themes/main_theme.tres` (police par défaut VT323, `default_font_size=32`, couleurs `Button`/`Label` gris clair + blanc au survol). Le thème est assigné à la racine de `scenes/main_menu.tscn` ; les `theme_override_*` redondants ont été retirés (le titre garde juste sa taille 64). Testé : la scène se charge sans erreur et le rendu change bien avec/sans le thème.
  - **Export web + GitHub Pages :** création de `.github/workflows/deploy_web.yml` — installe Godot 4.6.3 (image `barichello/godot-ci:4.6.3`), exporte le preset "Web" et déploie sur GitHub Pages (`actions/upload-pages-artifact` + `actions/deploy-pages`) à chaque push sur `main` (ou manuellement via `workflow_dispatch`).
  - **Correctif important :** `export_presets.cfg` passait `variant/thread_support=true`. Un export avec threads exige `SharedArrayBuffer`, donc des en-têtes COOP/COEP que **GitHub Pages ne fournit pas** → le jeu ne démarrerait pas. Le preset est passé en `variant/thread_support=false` (export vérifié : `GODOT_THREADS_ENABLED = false`). L'export a été testé en local (Godot 4.6.3 headless) et le build web chargé dans un navigateur : menu noir + texte gris clair correctement affiché, police VT323 incluse dans le `.pck`.
  - `.gitignore` : ajout de `build/` (dossier d'export généré par la CI, non versionné).
- **Décidé (par l'IA, à valider par Guillaume) :**
  - Police choisie : **VT323** (OFL) plutôt que VCR OSD Mono (licence plus floue pour un dépôt public).
  - Export web **sans threads** pour rester compatible GitHub Pages (pas de COOP/COEP possibles).
- **Reste à faire :**
  - **Guillaume doit activer GitHub Pages** dans Settings → Pages → Source = **GitHub Actions** (l'API GitHub ne permet pas de l'activer avec un token qui n'a pas les droits `pages`/admin ; à faire une fois côté web). Ensuite, chaque push sur `main` publiera le jeu.
  - Brancher les boutons quand les autres scènes existeront (New Game → première nuit, Continue → reprise, Settings → réglages).
  - Guillaume va raconter le lore complet de Guillaume Alves ("ça sera long à dire") → à noter en détail dans `LORE.md` §2.2 / §2.3.
  - Préciser pour chaque personnage : apparence, personnalité, origine/mort, mécanique spéciale, jumpscare, vitesse / lenteur par nuit.
  - Continuer la narration du lore (établissement, autres personnages) et du gameplay (bureau, caméras, survie, nuits).

### 2026-11-06 — Base de jeu FNaF complète
- **Fait :**
  - `scripts/data/game_config.gd` : tous les réglages (durée des heures, énergie, niveaux d'IA par nuit, caméras, scènes).
  - `scripts/autoload/save_manager.gd` (autoload `SaveManager`) : nuit courante / max / jeu terminé, sauvegardés dans `user://save.cfg` (IndexedDB du navigateur sur la version web).
  - `scripts/visuals/render_slot.gd` (`RenderSlot`) : chaque visuel cherche `assets/renders/<nom>[_<état>].png|jpg|webp`, sinon dessine une forme de `scripts/visuals/placeholders.gd`. Liste complète des noms/tailles : `assets/renders/README.md`.
  - `scripts/game/night_ai.gd` (`NightAI`) : IA FNaF 1 (jet 1-20 ≤ niveau), chemins des 4 esprits, Joey (cachette + course), Guillaume (nuit 5, bloqué quand on le regarde).
  - `scripts/game/office.gd` + `scenes/office.tscn` : bureau 1920 px scrollable (souris aux bords, flèches, Q/D), portes/lumières, énergie et panne, tablette caméras (survol de la barre ou Espace), HUD, jumpscare. Les nœuds sont construits en code ; positions en constantes en haut du fichier.
  - Scènes `night_intro`, `night_win`, `game_over`, `ending` ; menu branché (New Game / Continue avec « Night N » au survol / étoile si jeu fini). Résolution fixée à 1280 × 720 (stretch `canvas_items`).
  - Workflow : ajout d'une étape `godot --headless --import` pour que les nouvelles images soient importées en CI.
  - Testé en local (Godot 4.6.3) : import sans erreur, simulation de nuit (déplacements, porte fermée qui renvoie l'esprit, attaques), sauvegarde/rechargement, détection d'une image déposée, captures d'écran de toutes les scènes.
- **Décidé (par l'IA, à valider) :** valeurs et chemins de FNaF 1 ; noms de pièces en anglais ; attaquant de la panne = Super Clovis ; passage direct à la nuit suivante après « 6 AM » ; textes d'écran de fin provisoires.
- **Reste à faire :** ~~sons~~ (fait le 2026-11-07), appel téléphonique, effet de perspective « fausse 3D » du bureau (shader façon FNaF, optionnel), Settings, nuit 6 / custom night, mécaniques spéciales par esprit, vrais rendus 3D.

### 2026-11-07 — Sons de base (caméras, portes, jumpscares)
- **Fait :** autoload `Sfx` (`scripts/autoload/sound_manager.gd`). Même principe que les images : `assets/sounds/<nom>.ogg|wav|mp3` s'il existe, sinon son temporaire **synthétisé en code** (aucun fichier audio dans la repo). Liste : `assets/sounds/README.md`.
  - Caméras : ouverture/fermeture de la tablette, bip de changement de caméra, brouillage quand un esprit bouge, grésillement en boucle pendant qu'on regarde (et sur l'écran de game over).
  - Portes : fermeture, ouverture (aussi à la panne), Joey qui tape sur la porte, bouton qui ne répond plus ; bourdonnement des lumières.
  - Jumpscare : cri commun, ou `jumpscare_<perso>` si fourni.
  - Tous les sons sont préparés au début de la nuit (`Sfx.warm_up()`, ~60 ms). Coupés au jumpscare, à la panne et à la victoire.
- **Note web :** le navigateur n'autorise le son qu'après un clic : le clic sur « New Game / Continue » suffit.

---

## 5. Notes pour les prochaines sessions

1. Lire `IA.md` puis `LORE.md` en entier avant de commencer.
2. Vérifier l'état réel de la repo (nouveaux fichiers, scènes, scripts) et mettre à jour §1 / §3 si besoin.
3. Tout ce que Guillaume raconte : noter dans `LORE.md` en détail, sans faire le minimum.
4. Mettre à jour le journal §4 à la fin de chaque session de travail.
