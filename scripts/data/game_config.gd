class_name GameConfig
extends RefCounted
## Tous les réglages de gameplay au même endroit.
## Modifier les valeurs ici pour équilibrer le jeu (vitesse des nuits, IA, énergie...).
## Aucune logique ici : uniquement des données.

# --- Écran -------------------------------------------------------------------
const VIEW_SIZE := Vector2(1280, 720)
## Largeur du bureau (plus large que l'écran → on « tourne la tête » en scrollant).
const OFFICE_SIZE := Vector2(1920, 720)
## Vitesse max du scroll horizontal du bureau (pixels / seconde).
const OFFICE_SCROLL_SPEED := 1100.0
## Zone morte au centre de l'écran (fraction de largeur) où le bureau ne bouge pas.
const OFFICE_SCROLL_DEADZONE := 0.18
## Largeur de l'image d'une caméra (un peu plus large que l'écran → panoramique lent).
const CAM_IMAGE_SIZE := Vector2(1600, 720)

# --- Nuits -------------------------------------------------------------------
const LAST_NIGHT := 5
## Durée réelle d'une heure de jeu en secondes (FNaF 1 ≈ 89 s). 6 heures par nuit : 12 AM → 6 AM.
const HOUR_SECONDS := 86.0
const HOURS_PER_NIGHT := 6

# --- Énergie -----------------------------------------------------------------
## % d'énergie perdu par seconde et par barre d'utilisation (FNaF : 1 % toutes les 9,6 s).
const POWER_DRAIN_PER_USAGE := 1.0 / 9.6
## Durée max dans le noir après la panne avant le jumpscare (secondes, tirée au hasard).
const POWER_OUT_MIN_DELAY := 6.0
const POWER_OUT_MAX_DELAY := 20.0
## Qui attaque quand l'énergie est à 0. (Piste à valider par Guillaume.)
const POWER_OUT_KILLER := "clovis"

# --- Personnages -------------------------------------------------------------
## Identifiants internes (utilisés aussi dans les noms d'images : voir assets/renders/README.md).
const CHARACTERS := ["clovis", "paulhenri", "joey", "guillaume"]

const CHARACTER_NAMES := {
	"clovis": "Super Clovis",
	"paulhenri": "White Paul-Henri",
	"joey": "Joey Joestar",
	"guillaume": "Guillaume Alves",
	"adam": "Adam",
}

# --- Personnages secrets -------------------------------------------------------
## Adam : peut apparaître dans le bureau quand on baisse la tablette alors qu'on
## regardait la cam 1A. Chance = 1 sur ADAM_CHANCE[nuit] (index 0 = nuit 1).
const ADAM_CHANCE := [10000, 10000, 10000, 10000, 5000]
## Temps (s) pour relever la tablette avant qu'Adam attaque. S'il attaque, le jeu se ferme.
const ADAM_GRACE_TIME := 2.0
const ADAM_TRIGGER_CAMERA := "cam_1a"
## Position / taille d'Adam dans le bureau (il apparaît au centre de ce qu'on regarde).
const ADAM_SIZE := Vector2(360, 600)

## Intervalle (secondes) entre deux « chances de bouger » (comme FNaF : jet de 1 à 20 ≤ niveau d'IA).
const MOVE_INTERVAL := {
	"clovis": 4.97,
	"paulhenri": 4.98,
	"joey": 5.01,
	"guillaume": 3.02,
}

## Niveau d'IA (0 = immobile, 20 = max) par nuit. Index 0 = nuit 1.
## Clovis = le plus agressif, Paul-Henri = l'entre-deux, Joey = plus lent,
## Guillaume Alves = uniquement nuit 5 (canon, LORE.md).
const AI_LEVELS := {
	"clovis":    [3, 6, 9, 12, 15],
	"paulhenri": [1, 3, 6, 9, 12],
	"joey":      [1, 2, 5, 8, 11],
	"guillaume": [0, 0, 0, 0, 6],
}

## Bonus d'IA ajouté à certaines heures (heure de jeu : 1 = 1 AM ... 5 = 5 AM).
const AI_HOUR_BONUS := {
	"clovis":    {2: 1, 3: 1, 4: 1},
	"paulhenri": {3: 1, 4: 1},
	"joey":      {3: 1, 4: 1},
	"guillaume": {},
}

## Temps (s) qu'un esprit entré dans le bureau attend avant d'attaquer si on ne baisse pas la caméra.
const IN_OFFICE_FORCE_ATTACK := 20.0

## Joey : temps (s) entre sa sortie de la cachette et son arrivée à la porte gauche.
const JOEY_RUN_TIME := 22.0
## Joey : énergie retirée quand il frappe à une porte fermée (1er coup, puis +5 à chaque fois).
const JOEY_DOOR_DRAIN_FIRST := 1.0
const JOEY_DOOR_DRAIN_STEP := 5.0

# --- Caméras -----------------------------------------------------------------
## id → nom affiché. L'id sert aussi pour les images : assets/renders/cams/<id>.png
const CAMERAS := {
	"cam_1a": "Show Stage",
	"cam_1b": "Dining Area",
	"cam_1c": "Hidden Corner",
	"cam_2a": "West Hall",
	"cam_2b": "W. Hall Corner",
	"cam_3": "Supply Closet",
	"cam_4a": "East Hall",
	"cam_4b": "E. Hall Corner",
	"cam_5": "Backstage",
	"cam_6": "Kitchen",
	"cam_7": "Restrooms",
}
## Libellé court affiché sur le bouton de la carte.
const CAMERA_LABELS := {
	"cam_1a": "1A", "cam_1b": "1B", "cam_1c": "1C", "cam_2a": "2A", "cam_2b": "2B",
	"cam_3": "3", "cam_4a": "4A", "cam_4b": "4B", "cam_5": "5", "cam_6": "6", "cam_7": "7",
}
## Position des boutons sur la carte (coordonnées locales à la carte, 400 x 400).
const CAMERA_MAP_POS := {
	"cam_1a": Vector2(170, 20),
	"cam_1b": Vector2(150, 85),
	"cam_1c": Vector2(70, 150),
	"cam_5": Vector2(20, 90),
	"cam_7": Vector2(320, 100),
	"cam_6": Vector2(310, 210),
	"cam_3": Vector2(60, 250),
	"cam_2a": Vector2(130, 240),
	"cam_2b": Vector2(130, 305),
	"cam_4a": Vector2(230, 240),
	"cam_4b": Vector2(230, 305),
}
## Caméras sans image (audio seulement, comme la cuisine de FNaF 1).
const AUDIO_ONLY_CAMERAS := ["cam_6"]
const DEFAULT_CAMERA := "cam_1a"

# --- Scènes ------------------------------------------------------------------
const SCENE_MENU := "res://scenes/main_menu.tscn"
const SCENE_NIGHT_INTRO := "res://scenes/night_intro.tscn"
const SCENE_OFFICE := "res://scenes/office.tscn"
const SCENE_NIGHT_WIN := "res://scenes/night_win.tscn"
const SCENE_GAME_OVER := "res://scenes/game_over.tscn"
const SCENE_ENDING := "res://scenes/ending.tscn"


static func ai_level(character: String, night: int, hour: int) -> int:
	var levels: Array = AI_LEVELS[character]
	var level: int = levels[clampi(night, 1, levels.size()) - 1]
	var bonus: Dictionary = AI_HOUR_BONUS[character]
	for h: int in bonus:
		if hour >= h:
			level += bonus[h]
	return clampi(level, 0, 20)
