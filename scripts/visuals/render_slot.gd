@tool
class_name RenderSlot
extends Control
## Un « emplacement visuel » remplaçable.
##
## Fonctionnement (par ordre de priorité) :
##   1. Un GIF animé : res://assets/renders/<image_base>[_<state>].gif
##      (converti automatiquement en images par tools/convert_gifs.py → dossier _gif/).
##   2. Une image : res://assets/renders/<image_base>_<state>.png (ou .jpg / .webp),
##      puis res://assets/renders/<image_base>.png.
##   3. Sinon, une forme géométrique temporaire est dessinée (voir placeholders.gd).
##
## => Pour remplacer un décor ou un personnage par un rendu 3D, il suffit de déposer
##    l'image au bon nom dans assets/renders/ (liste complète : assets/renders/README.md).
##    Aucun code à modifier.

const RENDERS_DIR := "res://assets/renders/"
const GIF_DIR := "res://assets/renders/_gif/"
const EXTENSIONS := [".png", ".jpg", ".jpeg", ".webp"]

## Chemin de l'image sans extension, relatif à assets/renders/ (ex. "office/office").
@export var image_base: String = "":
	set(value):
		image_base = value
		_refresh()
## État optionnel (ex. "on"/"off", "0".."3"). Ajouté au nom de fichier : <image_base>_<state>.png
@export var state: String = "":
	set(value):
		if state == value:
			return
		state = value
		_refresh()
## Identifiant de la forme temporaire à dessiner si aucune image n'est trouvée.
@export var placeholder_id: String = "":
	set(value):
		placeholder_id = value
		queue_redraw()

static var _texture_cache: Dictionary = {}
static var _frames_cache: Dictionary = {}

var _texture: Texture2D = null
## Animation (GIF converti) si elle existe.
var _frames: SpriteFrames = null
var _frame_index: int = 0
var _frame_left: float = 0.0
var _anim_done: bool = false


func _init() -> void:
	# Un slot visuel ne bloque pas les clics (les boutons sont gérés à part).
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _ready() -> void:
	_refresh()


## Vrai si une vraie image ou un GIF est utilisé à la place de la forme temporaire.
func has_image() -> bool:
	return _texture != null or _frames != null


## Vrai si un GIF animé est utilisé.
func has_animation() -> bool:
	return _frames != null


## Durée d'un tour d'animation en secondes (0 si pas de GIF).
func animation_length() -> float:
	if _frames == null:
		return 0.0
	var total := 0.0
	for i in _frames.get_frame_count("default"):
		total += _frames.get_frame_duration("default", i)
	return total / maxf(_frames.get_animation_speed("default"), 0.001)


## Rejoue l'animation depuis la première image.
func restart_animation() -> void:
	_frame_index = 0
	_anim_done = false
	_frame_left = _current_frame_time()
	queue_redraw()


func _refresh() -> void:
	_texture = null
	_frames = null
	if image_base != "":
		if state != "":
			_frames = find_frames("%s_%s" % [image_base, state])
		if _frames == null:
			_frames = find_frames(image_base)
		if _frames == null and state != "":
			_texture = find_texture("%s_%s" % [image_base, state])
		if _frames == null and _texture == null:
			_texture = find_texture(image_base)
	set_process(_frames != null)
	if _frames != null:
		restart_animation()
	queue_redraw()


static func find_frames(base: String) -> SpriteFrames:
	if _frames_cache.has(base):
		return _frames_cache[base]
	var res: SpriteFrames = null
	var path: String = GIF_DIR + base + "/frames.tres"
	if ResourceLoader.exists(path):
		res = load(path) as SpriteFrames
		if res != null and (not res.has_animation("default") or res.get_frame_count("default") == 0):
			res = null
	_frames_cache[base] = res
	return res


func _current_frame_time() -> float:
	if _frames == null:
		return 0.0
	return _frames.get_frame_duration("default", _frame_index) / maxf(_frames.get_animation_speed("default"), 0.001)


func _process(delta: float) -> void:
	if _frames == null or _anim_done:
		return
	_frame_left -= delta
	var count := _frames.get_frame_count("default")
	var changed := false
	while _frame_left <= 0.0:
		if _frame_index + 1 >= count:
			if not _frames.get_animation_loop("default"):
				_anim_done = true
				break
			_frame_index = 0
		else:
			_frame_index += 1
		_frame_left += maxf(_current_frame_time(), 0.01)
		changed = true
	if changed:
		queue_redraw()


static func find_texture(base: String) -> Texture2D:
	if _texture_cache.has(base):
		return _texture_cache[base]
	var tex: Texture2D = null
	for ext: String in EXTENSIONS:
		var path: String = RENDERS_DIR + base + ext
		if ResourceLoader.exists(path):
			tex = load(path) as Texture2D
			if tex != null:
				break
	_texture_cache[base] = tex
	return tex


func _draw() -> void:
	if _frames != null:
		var tex := _frames.get_frame_texture("default", _frame_index)
		if tex != null:
			draw_texture_rect(tex, Rect2(Vector2.ZERO, size), false)
	elif _texture != null:
		draw_texture_rect(_texture, Rect2(Vector2.ZERO, size), false)
	elif placeholder_id != "":
		Placeholders.draw(self, placeholder_id, state, size)
