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
- **État actuel de la repo (au 2026-11-05) :** projet Godot squelette uniquement — `project.godot`, `icon.svg.import`, `.gitignore`, `LICENSE` (CC0), `README.md`. Aucun script, aucune scène, aucun asset de jeu pour l'instant.

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

- [ ] Boucle de jeu de base : FNaF classique (confirmé), 5 nuits (à confirmer), fonctionnalités spéciales par personnage (à définir)
- [ ] Bureau du joueur / poste de surveillance
- [ ] Système de caméras
- [ ] Les 4 esprits : Super Clovis (Bonnie, le plus agressif, en premier), White Paul-Henri (Chica, "l'entre deux"), Joey Joestar (Foxy), Guillaume Alves (Freddy, nuit 5 uniquement) — comportements, IA par nuit, mécaniques spéciales à définir
- [ ] Mécaniques de défense / survie (portes, lumière, bruit, énergie...)
- [ ] Jumpscares et game over
- [ ] Nuits, progression, difficulté
- [ ] Fin / secret / easter eggs
- [ ] Audio : ambiances, bruits, musique
- [ ] Interface : menu, briefing de nuit, écran de game over, écran de victoire

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

---

## 5. Notes pour les prochaines sessions

1. Lire `IA.md` puis `LORE.md` en entier avant de commencer.
2. Vérifier l'état réel de la repo (nouveaux fichiers, scènes, scripts) et mettre à jour §1 / §3 si besoin.
3. Tout ce que Guillaume raconte : noter dans `LORE.md` en détail, sans faire le minimum.
4. Mettre à jour le journal §4 à la fin de chaque session de travail.
