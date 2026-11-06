# Rendus 3D — où déposer les images

Chaque élément visuel du jeu est un **RenderSlot** (`scripts/visuals/render_slot.gd`).
Il affiche l'image ci-dessous **si elle existe**, sinon une forme géométrique temporaire.

**Pour remplacer une forme par un rendu : déposer le fichier au bon nom, pousser sur GitHub. C'est tout.**
Aucun code à modifier. Formats acceptés : `.png`, `.jpg`, `.jpeg`, `.webp` (PNG si transparence).
L'image est étirée au rectangle du slot : respecter les tailles conseillées (ou le même ratio).

> Astuce : pour les personnages, rendre la pièce **vide** une fois, puis chaque personnage
> **seul sur fond transparent, même cadrage, même taille**. Les calques se superposent tout seuls.

## Bureau (`office/`) — image large, on tourne la tête en scrollant

| Fichier | Taille | Contenu |
|---|---|---|
| `office/office.png` | 1920 × 720 | Le bureau complet (murs, sol, bureau, ventilo, affiches, encadrements de portes **noirs**) |
| `office/doorway_left_lit.png` | 260 × 460 | Couloir gauche vu par la porte, **lumière allumée**, vide |
| `office/doorway_right_lit.png` | 260 × 460 | Couloir droit, lumière allumée, vide |
| `office/doorway_left_clovis.png` | 260 × 460 | Super Clovis dans l'encadrement gauche (transparent, posé sur le couloir éclairé) |
| `office/doorway_right_paulhenri.png` | 260 × 460 | White Paul-Henri dans l'encadrement droit (transparent) |
| `office/door_left.png` / `door_right.png` | 260 × 460 | La porte métallique (descend quand on la ferme) |
| `office/panel_left.png` / `panel_right.png` | 90 × 230 | Boîtiers de boutons à côté des portes |
| `office/button_door_left_on.png` / `_off.png` | 70 × 70 | Bouton porte gauche (on = fermée). Idem `button_door_right_*` |
| `office/button_light_left_on.png` / `_off.png` | 70 × 70 | Bouton lumière gauche. Idem `button_light_right_*` |

Positions dans l'image du bureau (pour caler le rendu) : encadrement gauche x=140 y=120, droit x=1520 y=120 ;
boîtier gauche x=30 y=250, droit x=1800 y=250. Modifiables en haut de `scripts/game/office.gd`.

## Caméras (`cams/`) — 1600 × 720 (un peu plus large que l'écran : la caméra panote lentement)

Fond de chaque caméra (pièce vide) : `cams/<id>.png`

| id | Nom |
|---|---|
| `cam_1a` | Show Stage |
| `cam_1b` | Dining Area |
| `cam_1c` | Hidden Corner (cachette de Joey) |
| `cam_2a` | West Hall |
| `cam_2b` | W. Hall Corner |
| `cam_3` | Supply Closet |
| `cam_4a` | East Hall |
| `cam_4b` | E. Hall Corner |
| `cam_5` | Backstage |
| `cam_6` | Kitchen (audio seulement, pas d'image affichée) |
| `cam_7` | Restrooms |

Personnage dans une caméra (calque transparent 1600 × 720, même cadrage que le fond) : `cams/<id>_<perso>.png`

| Personnage (`<perso>`) | Caméras où il peut apparaître |
|---|---|
| `clovis` (Super Clovis) | cam_1a, cam_1b, cam_5, cam_2a, cam_3, cam_2b |
| `paulhenri` (White Paul-Henri) | cam_1a, cam_1b, cam_7, cam_4a, cam_4b (cam_6 = audio) |
| `guillaume` (Guillaume Alves, nuit 5) | cam_1a, cam_1b, cam_7, cam_4a, cam_4b (cam_6 = audio) |
| `joey` (Joey Joestar) | `cam_2a_joey.png` = Joey qui court dans le couloir |

Cachette de Joey (cam 1C) — une image par étape, calque sur `cam_1c.png` :
`cams/cam_1c_joey_0.png` (rideau fermé), `_1` (il regarde), `_2` (il sort), `_3` (parti, rideau ouvert).

## Jumpscares (`jumpscares/`) — 1280 × 720

`jumpscares/clovis.png`, `paulhenri.png`, `joey.png`, `guillaume.png`
(une image fixe pour l'instant, zoomée et secouée par le jeu).

## Interface (`ui/`)

| Fichier | Taille | Contenu |
|---|---|---|
| `ui/menu.png` | 1280 × 720 | Fond du menu principal (derrière le titre et les boutons) |
| `ui/map.png` | 400 × 400 | Plan des caméras (les boutons 1A, 1B... sont posés dessus) |
| `ui/cam_frame.png` | 1280 × 720 | Cadre/overlay par-dessus l'image caméra (transparent au centre) |
| `ui/cam_bar.png` | 600 × 44 | Barre « survoler pour ouvrir les caméras » |
| `ui/night_intro.png` | 1280 × 720 | Fond de l'écran « 12:00 AM / Night N » |
| `ui/night_win.png` | 1280 × 720 | Fond de l'écran « 6 AM » |
| `ui/game_over.png` | 1280 × 720 | Fond de l'écran de mort (sous la neige) |
| `ui/ending.png` | 1280 × 720 | Fond de l'écran de fin (après la nuit 5) |

## Où sont les formes temporaires ?

Toutes dans `scripts/visuals/placeholders.gd`. Elles ne servent plus dès que l'image correspondante existe.
La position des personnages en forme géométrique dans chaque caméra est dans `CAM_CHAR_POS` (même fichier) ;
avec de vrais rendus, c'est le cadrage de l'image qui compte.
