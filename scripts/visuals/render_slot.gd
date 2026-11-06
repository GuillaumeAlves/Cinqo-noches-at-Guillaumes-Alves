@tool
class_name RenderSlot
extends Control
## Un « emplacement visuel » remplaçable.
##
## Fonctionnement :
##   1. Le slot cherche une image dans res://assets/renders/<image_base>_<state>.png
##      (ou .jpg / .webp), puis res://assets/renders/<image_base>.png.
##   2. Si une image existe, elle est affichée en plein dans le rectangle du slot.
##   3. Sinon, une forme géométrique temporaire est dessinée (voir placeholders.gd).
##
## => Pour remplacer un décor ou un personnage par un rendu 3D, il suffit de déposer
##    l'image au bon nom dans assets/renders/ (liste complète : assets/renders/README.md).
##    Aucun code à modifier.

const RENDERS_DIR := "res://assets/renders/"
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

var _texture: Texture2D = null


func _init() -> void:
	# Un slot visuel ne bloque pas les clics (les boutons sont gérés à part).
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _ready() -> void:
	_refresh()


## Vrai si une vraie image (rendu) est utilisée à la place de la forme temporaire.
func has_image() -> bool:
	return _texture != null


func _refresh() -> void:
	_texture = null
	if image_base != "":
		if state != "":
			_texture = find_texture("%s_%s" % [image_base, state])
		if _texture == null:
			_texture = find_texture(image_base)
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
	if _texture != null:
		draw_texture_rect(_texture, Rect2(Vector2.ZERO, size), false)
	elif placeholder_id != "":
		Placeholders.draw(self, placeholder_id, state, size)
