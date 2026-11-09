extends CanvasLayer
## PANNEAU ADMIN (outil de test) — touche P pendant une nuit.
##
## Tout ce qui concerne le panneau est dans ce dossier admin/.
## Pour l'enlever du jeu : SUPPRIMER LE DOSSIER admin/ — rien d'autre à modifier
## (le bureau ne le charge que s'il existe, voir _load_admin_panel() dans office.gd).

const THEME_PATH := "res://admin/admin_theme.tres"
const ICON_PATH := "res://admin/admin_icon.svg"
const PANEL_RECT := Rect2(790, 8, 482, 704)

const JOEY_OPTIONS := ["1C : caché (rideau fermé)", "1C : il regarde", "1C : il sort", "2A : il court vers la porte"]

var office: Node
var _root: Control
var _status: Label
var _location_pickers := {}  # who -> OptionButton
var _location_rooms := {}    # who -> Array[String]
var _joey_picker: OptionButton
var _pause_btn: Button
var _freeze_btn: Button
var _adam_always_btn: Button
var _refresh_left := 0.0


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	office = get_parent()
	_build()
	_root.visible = false


func _unhandled_key_input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if k and k.pressed and not k.echo and k.keycode == KEY_P:
		toggle()
		get_viewport().set_input_as_handled()


func toggle() -> void:
	_root.visible = not _root.visible
	office.input_locked = _root.visible
	if _root.visible:
		_refresh_status()


func _process(delta: float) -> void:
	if not _root.visible:
		return
	_refresh_left -= delta
	if _refresh_left <= 0.0:
		_refresh_left = 0.25
		_refresh_status()


# =============================================================================
# Actions
# =============================================================================

func _set_location(who: String, index: int) -> void:
	var rooms: Array = _location_rooms[who]
	office.debug_set_location(who, rooms[index])


func _set_joey(index: int) -> void:
	if index >= 3:
		office.ai.force_joey_run()
	else:
		office.ai.force_joey_stage(index)
	office._refresh_camera()


func _jumpscare(who: String) -> void:
	_close_for_event()
	office.debug_jumpscare(who)


func _spawn_adam() -> void:
	_close_for_event()
	office.spawn_adam()


## Ferme le panneau et relance le jeu pour voir l'événement.
func _close_for_event() -> void:
	get_tree().paused = false
	_pause_btn.set_pressed_no_signal(false)
	_root.visible = false
	office.input_locked = false


# =============================================================================
# Affichage
# =============================================================================

func _refresh_status() -> void:
	if office == null or office.ai == null:
		return
	var ai: NightAI = office.ai
	var hour_txt: String = "12 AM" if office.hour == 0 else "%d AM" % office.hour
	var lines := PackedStringArray()
	lines.append("Nuit %d   %s (%ds)   Énergie %.1f %%   Usage %d" % [office.night, hour_txt, int(office.elapsed), office.power, office.usage()])
	lines.append("Caméras %s (%s)   IA %s" % ["levées" if office.monitor_up else "baissées", office.current_cam, "active" if ai.active else "figée"])
	for who: String in GameConfig.CHARACTERS:
		var extra := ""
		if who == "joey":
			extra = "  étape %d%s" % [ai.joey_stage, ("  course %.1fs" % ai.joey_run_timer) if ai.joey_run_timer >= 0.0 else ""]
		lines.append("%s : %s  (IA %d)%s" % [GameConfig.CHARACTER_NAMES[who], ai.location.get(who, "?"), ai.level(who), extra])
	lines.append("Adam : %s" % ("DANS LE BUREAU (%.1fs)" % office.adam_timer if office.adam_active else "absent"))
	_status.text = "\n".join(lines)
	# Met les listes déroulantes à jour (sauf si on est en train d'en ouvrir une).
	for who: String in _location_pickers:
		var picker: OptionButton = _location_pickers[who]
		if picker.get_popup().visible:
			continue
		var idx: int = (_location_rooms[who] as Array).find(ai.location.get(who, ""))
		if idx >= 0 and picker.selected != idx:
			picker.select(idx)
	if not _joey_picker.get_popup().visible:
		var j := 3 if ai.joey_stage >= 3 else ai.joey_stage
		if _joey_picker.selected != j:
			_joey_picker.select(j)
	_freeze_btn.set_pressed_no_signal(not ai.active)


# =============================================================================
# Construction de l'interface
# =============================================================================

func _build() -> void:
	_root = Control.new()
	_root.name = "AdminRoot"
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists(THEME_PATH):
		_root.theme = load(THEME_PATH)
	add_child(_root)

	var panel := PanelContainer.new()
	panel.position = PANEL_RECT.position
	panel.size = PANEL_RECT.size
	_root.add_child(panel)
	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 6)
	panel.add_child(outer)

	# En-tête
	var header := HBoxContainer.new()
	outer.add_child(header)
	if ResourceLoader.exists(ICON_PATH):
		var icon := TextureRect.new()
		icon.texture = load(ICON_PATH)
		icon.custom_minimum_size = Vector2(32, 32)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		header.add_child(icon)
	var title := Label.new()
	title.text = "ADMIN PANEL"
	title.add_theme_font_size_override("font_size", 32)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var close := Button.new()
	close.text = "[P] fermer"
	close.pressed.connect(toggle)
	header.add_child(close)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer.add_child(scroll)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 6)
	scroll.add_child(box)

	# --- État ---
	_status = Label.new()
	_status.add_theme_font_size_override("font_size", 18)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_status)

	# --- Partie ---
	_section(box, "PARTIE")
	var g := _grid(box)
	_pause_btn = _btn(g, "Pause du jeu", func() -> void: get_tree().paused = _pause_btn.button_pressed, true)
	_freeze_btn = _btn(g, "Figer l'IA", func() -> void: office.ai.active = not _freeze_btn.button_pressed, true)
	_btn(g, "Heure suivante", func() -> void: office.debug_next_hour())
	_btn(g, "Gagner la nuit (6 AM)", func() -> void:
		_close_for_event()
		office.debug_win_night())
	_btn(g, "Énergie 100 %", func() -> void: office.debug_set_power(100.0))
	_btn(g, "Énergie 5 %", func() -> void: office.debug_set_power(5.0))
	_btn(g, "Panne de courant", func() -> void:
		_close_for_event()
		office.debug_power_out())
	_btn(g, "Brouillage caméra", func() -> void:
		office._glitch_time = 0.8
		Sfx.play("cam_glitch"))

	# --- Positions ---
	_section(box, "POSITIONS")
	for who: String in ["clovis", "paulhenri", "guillaume"]:
		var rooms: Array[String] = []
		for room: String in NightAI.PATHS[who]:
			rooms.append(room)
		for extra: String in [NightAI.LEFT_DOOR if who == "clovis" else NightAI.RIGHT_DOOR, NightAI.OFFICE]:
			if extra not in rooms:
				rooms.append(extra)
		if who == "guillaume":
			rooms.erase(NightAI.RIGHT_DOOR)
		_location_rooms[who] = rooms
		var row := _row(box, GameConfig.CHARACTER_NAMES[who])
		var picker := OptionButton.new()
		picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		for room: String in rooms:
			picker.add_item(_room_label(room))
		picker.item_selected.connect(_set_location.bind(who))
		row.add_child(picker)
		_location_pickers[who] = picker
	var jrow := _row(box, "Joey Joestar")
	_joey_picker = OptionButton.new()
	_joey_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for opt: String in JOEY_OPTIONS:
		_joey_picker.add_item(opt)
	_joey_picker.item_selected.connect(_set_joey)
	jrow.add_child(_joey_picker)
	var jg := _grid(box)
	_btn(jg, "Joey sort de sa cove", func() -> void:
		office.ai.force_joey_run()
		office._refresh_camera())
	_btn(jg, "Joey arrive à la porte", func() -> void:
		_close_for_event()
		office.ai.force_joey_arrive())

	# --- Jumpscares ---
	_section(box, "JUMPSCARE INSTANTANÉ")
	var jsg := _grid(box)
	for who: String in GameConfig.CHARACTERS:
		_btn(jsg, GameConfig.CHARACTER_NAMES[who], _jumpscare.bind(who), false, true)
	_btn(jsg, "Adam (ferme le jeu)", _jumpscare.bind("adam"), false, true)

	# --- Secrets ---
	_section(box, "SECRETS")
	var sg := _grid(box)
	_btn(sg, "Faire apparaître Adam", _spawn_adam)
	_adam_always_btn = _btn(sg, "Adam 1/1 (cam 1A)", func() -> void: office.debug_adam_always = _adam_always_btn.button_pressed, true)
	var note := Label.new()
	note.text = "Adam : 1/%d (nuits 1-4), 1/%d (nuit 5) en baissant la tablette depuis la cam 1A. %.0f s pour relever la tablette, sinon jumpscare + fermeture du jeu." % [GameConfig.ADAM_CHANCE[0], GameConfig.ADAM_CHANCE[4], GameConfig.ADAM_GRACE_TIME]
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_font_size_override("font_size", 16)
	box.add_child(note)


func _room_label(room: String) -> String:
	if GameConfig.CAMERAS.has(room):
		return "%s %s" % [GameConfig.CAMERA_LABELS[room], GameConfig.CAMERAS[room]]
	match room:
		NightAI.LEFT_DOOR: return "Porte gauche"
		NightAI.RIGHT_DOOR: return "Porte droite"
		NightAI.OFFICE: return "DANS LE BUREAU"
	return room


func _section(parent: Node, txt: String) -> void:
	var sep := HSeparator.new()
	parent.add_child(sep)
	var l := Label.new()
	l.text = txt
	l.add_theme_font_size_override("font_size", 24)
	l.add_theme_color_override("font_color", Color(0.3, 1, 0.5))
	parent.add_child(l)


func _grid(parent: Node) -> GridContainer:
	var g := GridContainer.new()
	g.columns = 2
	g.add_theme_constant_override("h_separation", 6)
	g.add_theme_constant_override("v_separation", 6)
	g.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(g)
	return g


func _row(parent: Node, label: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	parent.add_child(row)
	var l := Label.new()
	l.text = label
	l.custom_minimum_size = Vector2(150, 0)
	row.add_child(l)
	return row


func _btn(parent: Node, txt: String, action: Callable, toggle_mode: bool = false, danger: bool = false) -> Button:
	var b := Button.new()
	b.text = txt
	b.toggle_mode = toggle_mode
	b.focus_mode = Control.FOCUS_NONE
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.clip_text = true
	if danger:
		b.theme_type_variation = &"DangerButton"
	b.pressed.connect(action)
	parent.add_child(b)
	return b
