@tool
class_name Placeholders
extends RefCounted
## Formes géométriques TEMPORAIRES dessinées directement par le moteur.
## Elles ne servent que tant qu'aucune image n'est déposée dans assets/renders/.
## Rien d'autre dans le jeu ne dépend de ce fichier : on peut le laisser tel quel
## une fois tous les rendus 3D en place.
##
## Format des identifiants : "<type>" ou "<type>/<argument>" (ex. "cam/cam_1a",
## "char_cam/clovis@cam_1a", "jumpscare/joey").

const CHAR_STYLE := {
	"clovis": {"body": Color(0.22, 0.32, 0.85), "eye": Color(1, 0.15, 0.15), "accent": Color(0.85, 0.1, 0.1)},
	"paulhenri": {"body": Color(0.92, 0.92, 0.95), "eye": Color(0.05, 0.05, 0.05), "accent": Color(0.15, 0.15, 0.15)},
	"joey": {"body": Color(0.9, 0.48, 0.12), "eye": Color(1, 0.9, 0.2), "accent": Color(1, 0.85, 0.1)},
	"guillaume": {"body": Color(0.45, 0.29, 0.16), "eye": Color(0.9, 0.9, 1), "accent": Color(0.08, 0.08, 0.08)},
	"adam": {"body": Color(0.06, 0.06, 0.07), "eye": Color(1, 1, 1), "accent": Color(0.6, 0, 0)},
}

## Position d'un personnage dans chaque caméra (fractions de l'image : x, y, largeur, hauteur).
const CAM_CHAR_POS := {
	"cam_1a": {"clovis": Rect2(0.28, 0.18, 0.13, 0.62), "paulhenri": Rect2(0.58, 0.18, 0.13, 0.62), "guillaume": Rect2(0.43, 0.14, 0.14, 0.66)},
	"cam_1b": {"clovis": Rect2(0.15, 0.25, 0.12, 0.55), "paulhenri": Rect2(0.68, 0.22, 0.12, 0.58), "guillaume": Rect2(0.44, 0.08, 0.06, 0.28)},
	"cam_5": {"clovis": Rect2(0.55, 0.15, 0.16, 0.75)},
	"cam_2a": {"clovis": Rect2(0.45, 0.22, 0.1, 0.5), "joey": Rect2(0.42, 0.25, 0.16, 0.6)},
	"cam_3": {"clovis": Rect2(0.42, 0.12, 0.17, 0.85)},
	"cam_2b": {"clovis": Rect2(0.62, 0.05, 0.22, 0.95)},
	"cam_7": {"paulhenri": Rect2(0.3, 0.15, 0.15, 0.75), "guillaume": Rect2(0.7, 0.2, 0.1, 0.5)},
	"cam_4a": {"paulhenri": Rect2(0.46, 0.22, 0.1, 0.5), "guillaume": Rect2(0.62, 0.3, 0.06, 0.25)},
	"cam_4b": {"paulhenri": Rect2(0.15, 0.05, 0.22, 0.95), "guillaume": Rect2(0.75, 0.28, 0.08, 0.4)},
}

static var _font: Font = null


static func font() -> Font:
	if _font == null:
		_font = load("res://fonts/VT323-Regular.ttf") as Font
		if _font == null:
			_font = ThemeDB.fallback_font
	return _font


static func draw(ci: CanvasItem, id: String, state: String, size: Vector2) -> void:
	var kind := id
	var arg := ""
	var slash := id.find("/")
	if slash >= 0:
		kind = id.substr(0, slash)
		arg = id.substr(slash + 1)
	match kind:
		"office": _office(ci, size)
		"doorway_lit": _doorway_lit(ci, size)
		"door": _door(ci, size)
		"panel": _panel(ci, size)
		"button": _button(ci, size, arg, state)
		"char_door": _char_door(ci, size, arg)
		"char_office": _character(ci, arg, Rect2(Vector2.ZERO, size), 1.0)
		"cam": _cam(ci, size, arg)
		"char_cam": _char_cam(ci, size, arg, state)
		"jumpscare": _jumpscare(ci, size, arg)
		"map": _map(ci, size)
		_:
			ci.draw_rect(Rect2(Vector2.ZERO, size), Color(1, 0, 1, 0.4))
			_text(ci, "?" + id, Vector2(8, 24), 20, Color.WHITE)


# --- Helpers -----------------------------------------------------------------

static func _text(ci: CanvasItem, txt: String, pos: Vector2, fsize: int, color: Color, width: float = -1, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> void:
	ci.draw_string(font(), pos, txt, align, width, fsize, color)


static func _poly(ci: CanvasItem, pts: Array, color: Color) -> void:
	ci.draw_colored_polygon(PackedVector2Array(pts), color)


static func _tiles(ci: CanvasItem, rect: Rect2, tile: float, a: Color, b: Color) -> void:
	ci.draw_rect(rect, a)
	var cols := int(ceil(rect.size.x / tile))
	var rows := int(ceil(rect.size.y / tile))
	for y in rows:
		for x in cols:
			if (x + y) % 2 == 0:
				var r := Rect2(rect.position + Vector2(x, y) * tile, Vector2(tile, tile)).intersection(rect)
				ci.draw_rect(r, b)


# --- Bureau ------------------------------------------------------------------

static func _office(ci: CanvasItem, s: Vector2) -> void:
	# Murs
	ci.draw_rect(Rect2(Vector2.ZERO, s), Color(0.13, 0.14, 0.17))
	ci.draw_rect(Rect2(0, 0, s.x, 70), Color(0.08, 0.08, 0.1))
	# Frise du mur
	_tiles(ci, Rect2(0, 400, s.x, 40), 20, Color(0.1, 0.1, 0.1), Color(0.55, 0.55, 0.55))
	# Sol en damier
	_tiles(ci, Rect2(0, 560, s.x, s.y - 560), 60, Color(0.07, 0.07, 0.08), Color(0.32, 0.32, 0.34))
	# Encadrements de portes (les couloirs sont noirs, la lumière les éclaire)
	for x: float in [140.0, s.x - 400.0]:
		ci.draw_rect(Rect2(x - 20, 100, 300, 480), Color(0.25, 0.25, 0.28))
		ci.draw_rect(Rect2(x, 120, 260, 460), Color(0.01, 0.01, 0.01))
	# Affiches
	ci.draw_rect(Rect2(560, 130, 220, 260), Color(0.55, 0.12, 0.12))
	_text(ci, "CELEBRATE ?", Vector2(560, 175), 34, Color(1, 0.9, 0.6), 220, HORIZONTAL_ALIGNMENT_CENTER)
	for i in 4:
		var key: String = GameConfig.CHARACTERS[i]
		var c: Color = CHAR_STYLE[key]["body"]
		ci.draw_circle(Vector2(590 + i * 53, 240), 18, c)
		ci.draw_rect(Rect2(578 + i * 53, 260, 24, 70), c)
	ci.draw_rect(Rect2(1150, 150, 180, 140), Color(0.85, 0.85, 0.75))
	_text(ci, "dessins", Vector2(1150, 180), 22, Color(0.2, 0.2, 0.2), 180, HORIZONTAL_ALIGNMENT_CENTER)
	for i in 3:
		ci.draw_circle(Vector2(1185 + i * 55, 235), 16, Color(0.2 + i * 0.25, 0.3, 0.7 - i * 0.2))
	ci.draw_rect(Rect2(1360, 170, 120, 160), Color(0.75, 0.8, 0.9))
	ci.draw_rect(Rect2(1375, 190, 90, 60), Color(0.3, 0.3, 0.35))
	# Bureau (meuble)
	ci.draw_rect(Rect2(520, 470, 880, 30), Color(0.3, 0.27, 0.24))
	ci.draw_rect(Rect2(540, 500, 840, 220), Color(0.2, 0.18, 0.16))
	# Écrans sur le bureau
	ci.draw_rect(Rect2(820, 330, 260, 150), Color(0.1, 0.1, 0.1))
	ci.draw_rect(Rect2(835, 345, 230, 115), Color(0.05, 0.12, 0.08))
	ci.draw_rect(Rect2(620, 380, 150, 100), Color(0.12, 0.12, 0.12))
	ci.draw_rect(Rect2(632, 392, 126, 76), Color(0.06, 0.1, 0.12))
	# Ventilateur
	ci.draw_rect(Rect2(1180, 440, 30, 40), Color(0.2, 0.2, 0.2))
	ci.draw_circle(Vector2(1195, 400), 55, Color(0.18, 0.18, 0.18))
	ci.draw_circle(Vector2(1195, 400), 45, Color(0.28, 0.28, 0.28))
	for i in 3:
		var ang := TAU / 3.0 * i
		var p := Vector2(1195, 400)
		_poly(ci, [p, p + Vector2.from_angle(ang - 0.35) * 42, p + Vector2.from_angle(ang + 0.35) * 42], Color(0.5, 0.5, 0.52))
	# Gobelet, papiers
	ci.draw_rect(Rect2(1110, 440, 30, 40), Color(0.85, 0.85, 0.85))
	ci.draw_rect(Rect2(700, 485, 120, 10), Color(0.9, 0.9, 0.85))
	# Lampe au plafond
	ci.draw_rect(Rect2(s.x / 2 - 80, 70, 160, 14), Color(0.6, 0.6, 0.5))
	_text(ci, "[placeholder]", Vector2(s.x / 2 - 60, 700), 18, Color(1, 1, 1, 0.25))


static func _doorway_lit(ci: CanvasItem, s: Vector2) -> void:
	# Couloir éclairé, perspective simple
	ci.draw_rect(Rect2(Vector2.ZERO, s), Color(0.35, 0.33, 0.25))
	var vp := Vector2(s.x / 2, s.y * 0.42)
	var back := Rect2(vp - Vector2(s.x * 0.18, s.y * 0.2), Vector2(s.x * 0.36, s.y * 0.4))
	_poly(ci, [Vector2(0, s.y), Vector2(s.x, s.y), back.end, Vector2(back.position.x, back.end.y)], Color(0.28, 0.27, 0.22))
	_poly(ci, [Vector2.ZERO, Vector2(s.x, 0), Vector2(back.end.x, back.position.y), back.position], Color(0.22, 0.21, 0.17))
	ci.draw_rect(back, Color(0.05, 0.05, 0.04))


static func _door(ci: CanvasItem, s: Vector2) -> void:
	ci.draw_rect(Rect2(Vector2.ZERO, s), Color(0.38, 0.39, 0.4))
	var y := 20.0
	while y < s.y:
		ci.draw_rect(Rect2(0, y, s.x, 6), Color(0.28, 0.29, 0.3))
		y += 40.0
	ci.draw_rect(Rect2(0, s.y - 24, s.x, 24), Color(0.85, 0.7, 0.1))
	for i in int(s.x / 30):
		_poly(ci, [Vector2(i * 30, s.y), Vector2(i * 30 + 15, s.y), Vector2(i * 30 + 30, s.y - 24), Vector2(i * 30 + 15, s.y - 24)], Color(0.1, 0.1, 0.1))


static func _panel(ci: CanvasItem, s: Vector2) -> void:
	ci.draw_rect(Rect2(Vector2.ZERO, s), Color(0.22, 0.22, 0.24))
	ci.draw_rect(Rect2(Vector2.ZERO, s), Color(0.05, 0.05, 0.05), false, 3.0)


static func _button(ci: CanvasItem, s: Vector2, kind: String, state: String) -> void:
	var on := state == "on"
	var c: Color
	if kind == "door":
		c = Color(0.95, 0.15, 0.15) if on else Color(0.35, 0.05, 0.05)
	else:
		c = Color(0.95, 0.95, 0.95) if on else Color(0.3, 0.3, 0.3)
	var r := minf(s.x, s.y) / 2.0
	ci.draw_circle(s / 2, r, Color(0.08, 0.08, 0.08))
	ci.draw_circle(s / 2, r * 0.8, c)
	_text(ci, "DOOR" if kind == "door" else "LIGHT", Vector2(0, s.y / 2 + 7), 18, Color(0, 0, 0) if on else Color(0.8, 0.8, 0.8), s.x, HORIZONTAL_ALIGNMENT_CENTER)


static func _char_door(ci: CanvasItem, s: Vector2, who: String) -> void:
	# Silhouette dans l'encadrement de la porte (vue quand la lumière est allumée)
	_character(ci, who, Rect2(s.x * 0.18, s.y * 0.08, s.x * 0.64, s.y * 0.95), 0.7)


# --- Personnages -------------------------------------------------------------

## Dessine un personnage générique dans le rectangle r. shade < 1 assombrit.
static func _character(ci: CanvasItem, who: String, r: Rect2, shade: float = 1.0) -> void:
	if not CHAR_STYLE.has(who):
		return
	var st: Dictionary = CHAR_STYLE[who]
	var body: Color = (st["body"] as Color).darkened(1.0 - shade)
	var accent: Color = (st["accent"] as Color).darkened(1.0 - shade)
	var eye: Color = st["eye"]
	var head_r := r.size.x * 0.32
	var head_c := r.position + Vector2(r.size.x / 2, head_r + r.size.y * 0.06)
	var torso := Rect2(r.position.x + r.size.x * 0.15, head_c.y + head_r * 0.8, r.size.x * 0.7, r.size.y * 0.45)
	# Signes distinctifs derrière le corps
	match who:
		"clovis":  # cape de « super »
			_poly(ci, [torso.position, Vector2(torso.end.x, torso.position.y), Vector2(torso.end.x + r.size.x * 0.12, r.end.y), Vector2(torso.position.x - r.size.x * 0.12, r.end.y)], accent)
		"guillaume":  # oreilles d'ours
			ci.draw_circle(head_c + Vector2(-head_r * 0.85, -head_r * 0.8), head_r * 0.38, body)
			ci.draw_circle(head_c + Vector2(head_r * 0.85, -head_r * 0.8), head_r * 0.38, body)
	# Jambes, bras, torse, tête
	var leg_w := r.size.x * 0.18
	ci.draw_rect(Rect2(torso.position.x + r.size.x * 0.08, torso.end.y, leg_w, r.end.y - torso.end.y), body.darkened(0.2))
	ci.draw_rect(Rect2(torso.end.x - r.size.x * 0.08 - leg_w, torso.end.y, leg_w, r.end.y - torso.end.y), body.darkened(0.2))
	ci.draw_rect(Rect2(torso.position.x - r.size.x * 0.12, torso.position.y + 6, r.size.x * 0.12, torso.size.y * 0.85), body.darkened(0.1))
	ci.draw_rect(Rect2(torso.end.x, torso.position.y + 6, r.size.x * 0.12, torso.size.y * 0.85), body.darkened(0.1))
	ci.draw_rect(torso, body)
	ci.draw_circle(head_c, head_r, body)
	# Yeux
	ci.draw_circle(head_c + Vector2(-head_r * 0.38, -head_r * 0.1), head_r * 0.2, Color(0, 0, 0))
	ci.draw_circle(head_c + Vector2(head_r * 0.38, -head_r * 0.1), head_r * 0.2, Color(0, 0, 0))
	ci.draw_circle(head_c + Vector2(-head_r * 0.38, -head_r * 0.1), head_r * 0.08, eye)
	ci.draw_circle(head_c + Vector2(head_r * 0.38, -head_r * 0.1), head_r * 0.08, eye)
	# Signes distinctifs devant
	match who:
		"clovis":
			_text(ci, "S", Vector2(torso.position.x, torso.position.y + torso.size.y * 0.6), int(torso.size.y * 0.5), Color(1, 0.85, 0.1).darkened(1.0 - shade), torso.size.x, HORIZONTAL_ALIGNMENT_CENTER)
		"paulhenri":  # nœud papillon
			var bc := Vector2(head_c.x, torso.position.y + 8)
			_poly(ci, [bc, bc + Vector2(-head_r * 0.5, -head_r * 0.22), bc + Vector2(-head_r * 0.5, head_r * 0.22)], accent)
			_poly(ci, [bc, bc + Vector2(head_r * 0.5, -head_r * 0.22), bc + Vector2(head_r * 0.5, head_r * 0.22)], accent)
		"joey":  # étoile
			_star(ci, torso.position + Vector2(torso.size.x * 0.25, torso.size.y * 0.25), torso.size.x * 0.14, accent)
		"guillaume":  # museau + chapeau
			ci.draw_circle(head_c + Vector2(0, head_r * 0.45), head_r * 0.35, body.lightened(0.25))
			ci.draw_circle(head_c + Vector2(0, head_r * 0.3), head_r * 0.12, Color(0, 0, 0))
			ci.draw_rect(Rect2(head_c.x - head_r * 0.4, head_c.y - head_r * 1.45, head_r * 0.8, head_r * 0.55), accent)
			ci.draw_rect(Rect2(head_c.x - head_r * 0.6, head_c.y - head_r * 0.95, head_r * 1.2, head_r * 0.12), accent)
	# Bouche
	ci.draw_rect(Rect2(head_c.x - head_r * 0.4, head_c.y + head_r * 0.55, head_r * 0.8, head_r * 0.12), Color(0, 0, 0, 0.8))


static func _star(ci: CanvasItem, c: Vector2, r: float, color: Color) -> void:
	var pts: Array = []
	for i in 10:
		var rr := r if i % 2 == 0 else r * 0.45
		pts.append(c + Vector2.from_angle(-PI / 2 + i * PI / 5) * rr)
	_poly(ci, pts, color)


static func _char_cam(ci: CanvasItem, s: Vector2, arg: String, state: String) -> void:
	var parts := arg.split("@")
	if parts.size() < 2:
		return
	var who := parts[0]
	var cam := parts[1]
	if who == "joey" and cam == "cam_1c":
		_joey_cove(ci, s, state)
		return
	if who == "joey" and cam == "cam_2a":
		# Joey qui court dans le couloir
		var rr := Rect2(s.x * 0.38, s.y * 0.2, s.x * 0.22, s.y * 0.8)
		_character(ci, who, rr)
		_poly(ci, [Vector2(rr.position.x - 60, rr.position.y + 120), Vector2(rr.position.x - 10, rr.position.y + 140), Vector2(rr.position.x - 60, rr.position.y + 160)], Color(1, 1, 1, 0.3))
		return
	var cam_pos: Dictionary = CAM_CHAR_POS.get(cam, {})
	if not cam_pos.has(who):
		return
	var f: Rect2 = cam_pos[who]
	_character(ci, who, Rect2(f.position * s, f.size * s), 0.85)


## Cachette de Joey (cam 1C) : 0 rideau fermé, 1 il regarde, 2 il sort, 3 parti.
static func _joey_cove(ci: CanvasItem, s: Vector2, state: String) -> void:
	var stage := int(state) if state.is_valid_int() else 0
	var curtain := Rect2(s.x * 0.3, s.y * 0.12, s.x * 0.4, s.y * 0.72)
	var cc := Color(0.35, 0.12, 0.45)
	if stage >= 1 and stage <= 2:
		var rr := Rect2(curtain.position.x + curtain.size.x * (0.35 if stage == 1 else 0.3), curtain.position.y + 20, curtain.size.x * (0.3 if stage == 1 else 0.4), curtain.size.y)
		_character(ci, "joey", rr, 0.8)
	if stage == 0:
		ci.draw_rect(curtain, cc)
	elif stage == 1:
		ci.draw_rect(Rect2(curtain.position, Vector2(curtain.size.x * 0.42, curtain.size.y)), cc)
		ci.draw_rect(Rect2(curtain.position + Vector2(curtain.size.x * 0.58, 0), Vector2(curtain.size.x * 0.42, curtain.size.y)), cc)
	else:
		ci.draw_rect(Rect2(curtain.position, Vector2(curtain.size.x * 0.18, curtain.size.y)), cc)
		ci.draw_rect(Rect2(curtain.position + Vector2(curtain.size.x * 0.82, 0), Vector2(curtain.size.x * 0.18, curtain.size.y)), cc)
	for i in 8:
		var x := curtain.position.x + curtain.size.x / 8.0 * i
		if stage == 0:
			ci.draw_line(Vector2(x, curtain.position.y), Vector2(x, curtain.end.y), cc.darkened(0.3), 3)
	if stage >= 3:
		ci.draw_rect(Rect2(s.x * 0.42, s.y * 0.4, s.x * 0.16, s.y * 0.12), Color(0.9, 0.9, 0.85))
		_text(ci, "OUT OF ORDER", Vector2(s.x * 0.42, s.y * 0.48), 30, Color(0.6, 0.1, 0.1), s.x * 0.16, HORIZONTAL_ALIGNMENT_CENTER)


static func _jumpscare(ci: CanvasItem, s: Vector2, who: String) -> void:
	ci.draw_rect(Rect2(Vector2.ZERO, s), Color(0, 0, 0, 0.6))
	if not CHAR_STYLE.has(who):
		return
	var st: Dictionary = CHAR_STYLE[who]
	var c := s / 2 + Vector2(0, 40)
	var r := s.y * 0.55
	var body: Color = st["body"]
	if who == "guillaume":
		ci.draw_circle(c + Vector2(-r * 0.8, -r * 0.75), r * 0.32, body)
		ci.draw_circle(c + Vector2(r * 0.8, -r * 0.75), r * 0.32, body)
	ci.draw_circle(c, r, body)
	# Yeux
	for sx: float in [-1.0, 1.0]:
		ci.draw_circle(c + Vector2(sx * r * 0.38, -r * 0.25), r * 0.2, Color(0, 0, 0))
		ci.draw_circle(c + Vector2(sx * r * 0.38, -r * 0.25), r * 0.07, st["eye"])
	# Bouche grande ouverte + dents
	var mouth := Rect2(c.x - r * 0.55, c.y + r * 0.1, r * 1.1, r * 0.55)
	ci.draw_rect(mouth, Color(0.05, 0, 0))
	var n := 8
	for i in n:
		var x := mouth.position.x + mouth.size.x / n * i
		var w := mouth.size.x / n
		_poly(ci, [Vector2(x, mouth.position.y), Vector2(x + w, mouth.position.y), Vector2(x + w / 2, mouth.position.y + r * 0.13)], Color(0.95, 0.95, 0.85))
		_poly(ci, [Vector2(x, mouth.end.y), Vector2(x + w, mouth.end.y), Vector2(x + w / 2, mouth.end.y - r * 0.13)], Color(0.95, 0.95, 0.85))
	_text(ci, GameConfig.CHARACTER_NAMES.get(who, who).to_upper(), Vector2(0, s.y - 20), 40, Color(1, 1, 1, 0.5), s.x, HORIZONTAL_ALIGNMENT_CENTER)


# --- Caméras -----------------------------------------------------------------

static func _cam(ci: CanvasItem, s: Vector2, cam: String) -> void:
	# Pièce générique : mur + sol
	ci.draw_rect(Rect2(Vector2.ZERO, s), Color(0.16, 0.17, 0.16))
	_tiles(ci, Rect2(0, s.y * 0.72, s.x, s.y * 0.28), 48, Color(0.08, 0.08, 0.08), Color(0.25, 0.25, 0.25))
	match cam:
		"cam_1a":  # scène de spectacle
			ci.draw_rect(Rect2(s.x * 0.15, s.y * 0.75, s.x * 0.7, s.y * 0.1), Color(0.25, 0.15, 0.1))
			ci.draw_rect(Rect2(s.x * 0.1, 0, s.x * 0.08, s.y * 0.85), Color(0.45, 0.08, 0.1))
			ci.draw_rect(Rect2(s.x * 0.82, 0, s.x * 0.08, s.y * 0.85), Color(0.45, 0.08, 0.1))
			for i in 12:
				ci.draw_circle(Vector2(s.x * (0.2 + i * 0.055), s.y * 0.05), 8, Color(0.9, 0.85, 0.4))
		"cam_1b":  # salle à manger
			for i in 3:
				for j in 2:
					var t := Rect2(s.x * (0.12 + i * 0.28), s.y * (0.55 + j * 0.15), s.x * 0.2, s.y * 0.06)
					ci.draw_rect(t, Color(0.85, 0.85, 0.85))
					for k in 4:
						_poly(ci, [Vector2(t.position.x + 20 + k * 60, t.position.y), Vector2(t.position.x + 35 + k * 60, t.position.y - 25), Vector2(t.position.x + 50 + k * 60, t.position.y)], Color(0.3 + k * 0.15, 0.2, 0.6))
		"cam_1c":  # cachette de Joey
			ci.draw_rect(Rect2(s.x * 0.28, s.y * 0.08, s.x * 0.44, s.y * 0.8), Color(0.05, 0.03, 0.06))
			for i in 12:
				_star(ci, Vector2(s.x * (0.08 + (i % 4) * 0.06), s.y * (0.2 + floorf(i / 4.0) * 0.18)), 14, Color(0.9, 0.85, 0.3, 0.6))
		"cam_2a", "cam_4a":  # couloirs
			_hallway(ci, s)
			if cam == "cam_2a":
				ci.draw_rect(Rect2(s.x * 0.12, s.y * 0.2, s.x * 0.1, s.y * 0.15), Color(0.8, 0.8, 0.7))
		"cam_2b", "cam_4b":  # coins de couloir, près du bureau
			_hallway(ci, s)
			ci.draw_rect(Rect2(s.x * 0.35, s.y * 0.2, s.x * 0.15, s.y * 0.25), Color(0.75, 0.72, 0.6))
			_text(ci, "IT'S ME" if cam == "cam_2b" else "SMILE", Vector2(s.x * 0.35, s.y * 0.35), 36, Color(0.5, 0.1, 0.1), s.x * 0.15, HORIZONTAL_ALIGNMENT_CENTER)
		"cam_3":  # placard
			for i in 4:
				ci.draw_rect(Rect2(s.x * 0.1, s.y * (0.15 + i * 0.15), s.x * 0.25, 10), Color(0.4, 0.3, 0.2))
				ci.draw_rect(Rect2(s.x * 0.65, s.y * (0.15 + i * 0.15), s.x * 0.25, 10), Color(0.4, 0.3, 0.2))
				ci.draw_rect(Rect2(s.x * (0.12 + i * 0.05), s.y * (0.15 + i * 0.15) - 40, 50, 40), Color(0.3, 0.3, 0.5))
		"cam_5":  # coulisses : têtes de rechange
			ci.draw_rect(Rect2(s.x * 0.05, s.y * 0.45, s.x * 0.4, s.y * 0.08), Color(0.3, 0.25, 0.2))
			for i in 4:
				ci.draw_circle(Vector2(s.x * (0.1 + i * 0.09), s.y * 0.38), s.y * 0.07, Color(0.35 + i * 0.1, 0.3, 0.3))
		"cam_7":  # toilettes
			for i in 4:
				ci.draw_rect(Rect2(s.x * (0.08 + i * 0.22), s.y * 0.15, s.x * 0.18, s.y * 0.6), Color(0.45, 0.5, 0.55))
				ci.draw_rect(Rect2(s.x * (0.08 + i * 0.22), s.y * 0.15, s.x * 0.18, s.y * 0.6), Color(0.2, 0.2, 0.2), false, 4)
		"cam_6":
			ci.draw_rect(Rect2(Vector2.ZERO, s), Color(0, 0, 0))
	_text(ci, "[placeholder] " + GameConfig.CAMERAS.get(cam, cam), Vector2(s.x * 0.5 - 200, s.y - 20), 22, Color(1, 1, 1, 0.25), 400, HORIZONTAL_ALIGNMENT_CENTER)


static func _hallway(ci: CanvasItem, s: Vector2) -> void:
	var back := Rect2(s.x * 0.4, s.y * 0.25, s.x * 0.2, s.y * 0.4)
	_poly(ci, [Vector2(0, 0), back.position, Vector2(back.position.x, back.end.y), Vector2(0, s.y)], Color(0.2, 0.2, 0.22))
	_poly(ci, [Vector2(s.x, 0), Vector2(back.end.x, back.position.y), back.end, Vector2(s.x, s.y)], Color(0.18, 0.18, 0.2))
	_poly(ci, [Vector2(0, s.y), Vector2(back.position.x, back.end.y), back.end, Vector2(s.x, s.y)], Color(0.12, 0.12, 0.12))
	ci.draw_rect(back, Color(0.02, 0.02, 0.02))


static func _map(ci: CanvasItem, s: Vector2) -> void:
	var c := Color(1, 1, 1, 0.8)
	var w := 3.0
	# Contour très simplifié du bâtiment
	ci.draw_rect(Rect2(40, 10, 260, 60), c, false, w)  # scène / salle
	ci.draw_rect(Rect2(10, 70, 360, 140), c, false, w)  # salle à manger
	ci.draw_rect(Rect2(120, 210, 50, 160), c, false, w)  # couloir ouest
	ci.draw_rect(Rect2(220, 210, 50, 160), c, false, w)  # couloir est
	ci.draw_rect(Rect2(170, 320, 50, 50), c, false, w)  # bureau
	_text(ci, "YOU", Vector2(170, 352), 20, Color(1, 1, 1), 50, HORIZONTAL_ALIGNMENT_CENTER)
