class_name NightAI
extends Node
## IA des esprits pendant une nuit (logique pure, aucun visuel).
## Règles de base copiées de FNaF 1 :
##  - toutes les MOVE_INTERVAL secondes, chaque esprit tire un nombre de 1 à 20 ;
##    s'il est ≤ à son niveau d'IA, il avance d'une pièce.
##  - Super Clovis (≈ Bonnie) arrive par la porte GAUCHE.
##  - White Paul-Henri (≈ Chica) arrive par la porte DROITE.
##  - Joey Joestar (≈ Foxy) sort de sa cachette (cam 1C) quand on ne regarde PAS
##    les caméras, puis court vers la porte gauche.
##  - Guillaume Alves (≈ Freddy, nuit 5 seulement) ne bouge pas quand on le regarde
##    et entre par la droite.

signal moved(who: String, from_room: String, to_room: String)
signal entered_office(who: String)
signal attack(who: String)
signal joey_door_hit(power_drain: float)
signal joey_stage_changed(stage: int)

## Pièces spéciales (en plus des id de caméras).
const LEFT_DOOR := "left_door"
const RIGHT_DOOR := "right_door"
const OFFICE := "office"

## Chemins possibles : pièce → pièces suivantes (tirées au hasard).
const PATHS := {
	"clovis": {
		"cam_1a": ["cam_1b", "cam_5"],
		"cam_1b": ["cam_5", "cam_2a"],
		"cam_5": ["cam_1b", "cam_2a"],
		"cam_2a": ["cam_3", "cam_2b"],
		"cam_3": ["cam_2a", "cam_2b"],
		"cam_2b": [LEFT_DOOR, "cam_3"],
	},
	"paulhenri": {
		"cam_1a": ["cam_1b"],
		"cam_1b": ["cam_7", "cam_6"],
		"cam_7": ["cam_6", "cam_4a"],
		"cam_6": ["cam_7", "cam_4a"],
		"cam_4a": ["cam_4b", "cam_1b"],
		"cam_4b": [RIGHT_DOOR, "cam_4a"],
	},
	"guillaume": {
		"cam_1a": ["cam_1b"],
		"cam_1b": ["cam_7"],
		"cam_7": ["cam_6"],
		"cam_6": ["cam_4a"],
		"cam_4a": ["cam_4b"],
		"cam_4b": [OFFICE],
	},
}
## Où l'esprit repart quand il trouve une porte fermée.
const RETREAT := {"clovis": "cam_1b", "paulhenri": "cam_1b", "guillaume": "cam_4a"}
const DOOR_SIDE := {"clovis": "left", "paulhenri": "right", "guillaume": "right"}
const START_ROOM := {"clovis": "cam_1a", "paulhenri": "cam_1a", "guillaume": "cam_1a", "joey": "cam_1c"}

## Doit fournir : is_door_closed(side) -> bool, is_monitor_up() -> bool, current_camera() -> String
var office: Node
var night: int = 1
var hour: int = 0
var active: bool = true

var location: Dictionary = {}
var in_office: Array[String] = []
var joey_stage: int = 0  # 0 caché, 1 regarde, 2 sort, 3 parti (court)
var joey_run_timer: float = -1.0
var joey_hits: int = 0

var _timers: Dictionary = {}
var _in_office_timer: float = 0.0


func setup(p_office: Node, p_night: int) -> void:
	office = p_office
	night = p_night
	for who: String in GameConfig.CHARACTERS:
		location[who] = START_ROOM[who]
		# Décalage aléatoire pour que tout le monde ne bouge pas à la même frame
		_timers[who] = randf() * GameConfig.MOVE_INTERVAL[who]


func level(who: String) -> int:
	return GameConfig.ai_level(who, night, hour)


func is_at(who: String, room: String) -> bool:
	return location.get(who, "") == room


## Liste des esprits présents dans une pièce/caméra.
func who_is_in(room: String) -> Array[String]:
	var res: Array[String] = []
	for who: String in location:
		if location[who] == room:
			res.append(who)
	return res


func _process(delta: float) -> void:
	if not active:
		return
	for who: String in GameConfig.CHARACTERS:
		_timers[who] -= delta
		if _timers[who] <= 0.0:
			_timers[who] += GameConfig.MOVE_INTERVAL[who]
			var lvl := level(who)
			if lvl > 0 and randi_range(1, 20) <= lvl:
				_move_opportunity(who)
	_process_joey_run(delta)
	if not in_office.is_empty():
		_in_office_timer += delta
		if _in_office_timer >= GameConfig.IN_OFFICE_FORCE_ATTACK:
			_attack(in_office[0])


## Appelé par le bureau quand le joueur baisse la caméra.
func on_monitor_lowered() -> void:
	if active and not in_office.is_empty():
		_attack(in_office[0])


## Appelé par le bureau quand le joueur change de caméra.
func on_camera_viewed(cam: String) -> void:
	# Regarder le couloir ouest pendant que Joey court le fait sprinter.
	if cam == "cam_2a" and joey_run_timer > 1.8:
		joey_run_timer = 1.8


func _move_opportunity(who: String) -> void:
	if who == "joey":
		_joey_opportunity()
		return
	if who in in_office:
		return
	var room: String = location[who]
	# Guillaume Alves ne bouge pas quand on le regarde.
	if who == "guillaume" and office.is_monitor_up() and office.current_camera() == room:
		return
	if room == LEFT_DOOR or room == RIGHT_DOOR:
		_try_enter(who)
		return
	var options: Array = PATHS[who].get(room, [])
	if options.is_empty():
		return
	var target: String = options.pick_random()
	if target == OFFICE:
		_try_enter(who)
		return
	_set_location(who, target)


func _try_enter(who: String) -> void:
	if office.is_door_closed(DOOR_SIDE[who]):
		_set_location(who, RETREAT[who])
		return
	# Guillaume n'entre que si on regarde ailleurs (pas sur la cam 4B).
	if who == "guillaume" and office.is_monitor_up() and office.current_camera() == "cam_4b":
		return
	if who == "guillaume" and not office.is_monitor_up():
		return
	_set_location(who, OFFICE)
	in_office.append(who)
	_in_office_timer = 0.0
	entered_office.emit(who)


func _joey_opportunity() -> void:
	if joey_stage >= 3:
		return
	# Joey ne bouge pas tant qu'on regarde les caméras.
	if office.is_monitor_up():
		return
	joey_stage += 1
	joey_stage_changed.emit(joey_stage)
	if joey_stage == 3:
		_set_location("joey", "cam_2a")
		joey_run_timer = GameConfig.JOEY_RUN_TIME


func _process_joey_run(delta: float) -> void:
	if joey_run_timer < 0.0:
		return
	joey_run_timer -= delta
	if joey_run_timer > 0.0:
		return
	joey_run_timer = -1.0
	if office.is_door_closed("left"):
		var drain := GameConfig.JOEY_DOOR_DRAIN_FIRST + GameConfig.JOEY_DOOR_DRAIN_STEP * joey_hits
		joey_hits += 1
		joey_stage = randi_range(0, 1)
		_set_location("joey", "cam_1c")
		joey_stage_changed.emit(joey_stage)
		joey_door_hit.emit(drain)
	else:
		_set_location("joey", OFFICE)
		_attack("joey")


func _set_location(who: String, room: String) -> void:
	var from: String = location[who]
	location[who] = room
	moved.emit(who, from, room)


func _attack(who: String) -> void:
	if not active:
		return
	active = false
	attack.emit(who)
