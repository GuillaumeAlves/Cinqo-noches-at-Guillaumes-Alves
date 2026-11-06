extends Node
## Autoload « SaveManager » — sauvegarde de la progression.
## Le fichier est écrit dans user:// : sur la version web, Godot le stocke dans
## l'IndexedDB du navigateur, donc la nuit atteinte reste après un rechargement de page.

const SAVE_PATH := "user://save.cfg"
const SECTION := "progress"

## Nuit à jouer avec « Continue » (1 à 5).
var current_night: int = 1
## Plus haute nuit débloquée.
var max_night: int = 1
## Les 5 nuits ont été terminées au moins une fois.
var game_completed: bool = false

## Nuit en cours de partie (celle qu'on est en train de jouer).
var playing_night: int = 1


func _ready() -> void:
	load_game()


func load_game() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	current_night = clampi(int(cfg.get_value(SECTION, "current_night", 1)), 1, GameConfig.LAST_NIGHT)
	max_night = clampi(int(cfg.get_value(SECTION, "max_night", current_night)), 1, GameConfig.LAST_NIGHT)
	game_completed = bool(cfg.get_value(SECTION, "game_completed", false))


func save_game() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value(SECTION, "current_night", current_night)
	cfg.set_value(SECTION, "max_night", max_night)
	cfg.set_value(SECTION, "game_completed", game_completed)
	var err := cfg.save(SAVE_PATH)
	if err != OK:
		push_warning("Sauvegarde impossible (%s)" % error_string(err))


## New Game : on repart de la nuit 1.
func start_new_game() -> void:
	current_night = 1
	save_game()
	start_night(1)


## Continue : on reprend à la nuit sauvegardée.
func continue_game() -> void:
	start_night(current_night)


func start_night(night: int) -> void:
	playing_night = clampi(night, 1, GameConfig.LAST_NIGHT)
	get_tree().change_scene_to_file(GameConfig.SCENE_NIGHT_INTRO)


## Appelé quand le joueur survit jusqu'à 6 AM.
func complete_night() -> void:
	if playing_night >= GameConfig.LAST_NIGHT:
		game_completed = true
		current_night = GameConfig.LAST_NIGHT
	else:
		current_night = maxi(current_night, playing_night + 1)
	max_night = maxi(max_night, current_night)
	save_game()


## Le joueur a déjà une partie en cours (pour afficher « Continue »).
func has_progress() -> bool:
	return current_night > 1 or game_completed
