extends Control
## Scène de jeu principale : le bureau + les caméras + le HUD.
##
## Tous les visuels sont des RenderSlot (voir scripts/visuals/render_slot.gd) :
## ils affichent l'image assets/renders/<chemin>.png si elle existe, sinon une forme
## géométrique temporaire. Les positions/tailles sont regroupées dans les constantes
## ci-dessous pour pouvoir caler facilement les rendus 3D.

# --- Mise en page du bureau (coordonnées dans l'image du bureau 1920 x 720) ---
const DOORWAY_LEFT := Rect2(140, 120, 260, 460)
const DOORWAY_RIGHT := Rect2(1520, 120, 260, 460)
const PANEL_LEFT := Rect2(30, 250, 90, 230)
const PANEL_RIGHT := Rect2(1800, 250, 90, 230)
const BUTTON_SIZE := Vector2(70, 70)
const DOOR_ANIM_TIME := 0.25

# --- Mise en page des caméras (coordonnées écran 1280 x 720) ---
const MAP_RECT := Rect2(850, 290, 400, 400)
const CAM_BAR_RECT := Rect2(340, 668, 600, 44)
const CAM_PAN_TIME := 6.0
const MONITOR_FLIP_TIME := 0.22

# --- État de la nuit ---
var night: int = 1
var elapsed: float = 0.0
var hour: int = 0
var power: float = 100.0
var power_out: bool = false
var game_finished: bool = false

var door_closed := {"left": false, "right": false}
var light_on := {"left": false, "right": false}
var side_broken := {"left": false, "right": false}
var monitor_up: bool = false
var monitor_animating: bool = false
var current_cam: String = GameConfig.DEFAULT_CAMERA
var scroll_x: float = 0.0

var ai: NightAI

# --- Nœuds construits dans _build() ---
var world: Control
var doorways := {}      # side -> Control (clip)
var doorway_light := {} # side -> RenderSlot
var doorway_chars := {} # side -> {who: RenderSlot}
var doors := {}         # side -> RenderSlot
var door_buttons := {}  # side -> RenderSlot
var light_buttons := {} # side -> RenderSlot
var darkness: ColorRect
var monitor: Control
var cam_image: Control
var cam_background: RenderSlot
var cam_chars := {}     # who -> RenderSlot
var cam_static: ColorRect
var cam_static_mat: ShaderMaterial
var cam_name_label: Label
var audio_only_label: Label
var rec_label: Label
var cam_buttons := {}   # cam -> Button
var flip_rect: ColorRect
var time_label: Label
var night_label: Label
var power_label: Label
var usage_bars: Array[ColorRect] = []
var cam_bar: Control
var jumpscare_slot: RenderSlot

var _cam_bar_armed: bool = true
var _cam_pan_tween: Tween
var _glitch_time: float = 0.0
var _rec_blink: float = 0.0


func _ready() -> void:
	night = SaveManager.playing_night
	Sfx.warm_up()
	_build()
	ai = NightAI.new()
	ai.name = "NightAI"
	add_child(ai)
	ai.setup(self, night)
	ai.moved.connect(_on_spirit_moved)
	ai.attack.connect(_on_attack)
	ai.entered_office.connect(_on_spirit_entered)
	ai.joey_door_hit.connect(_on_joey_door_hit)
	ai.joey_stage_changed.connect(func(_s: int) -> void: _refresh_camera())
	_refresh_all()
	_update_ambience()


# =============================================================================
# Interface utilisée par NightAI
# =============================================================================

func is_door_closed(side: String) -> bool:
	return door_closed[side]


func is_monitor_up() -> bool:
	return monitor_up


func current_camera() -> String:
	return current_cam


# =============================================================================
# Boucle
# =============================================================================

func _exit_tree() -> void:
	Sfx.stop("cam_static")
	Sfx.stop("light_buzz")
	Sfx.stop("office_ambience")


## Néon d'ambiance : uniquement quand on est dans le bureau (caméras baissées),
## coupé pendant les caméras, la panne de courant, le jumpscare et la victoire.
func _update_ambience() -> void:
	if not monitor_up and not power_out and not game_finished:
		Sfx.play_loop("office_ambience")
	else:
		Sfx.stop("office_ambience")


func _process(delta: float) -> void:
	if game_finished:
		return
	_process_time(delta)
	if game_finished:
		return
	_process_power(delta)
	_process_scroll(delta)
	_process_monitor_fx(delta)


func _process_time(delta: float) -> void:
	elapsed += delta
	var new_hour := int(elapsed / GameConfig.HOUR_SECONDS)
	if new_hour != hour:
		hour = new_hour
		ai.hour = hour
		_update_hud()
	if hour >= GameConfig.HOURS_PER_NIGHT:
		_win_night()


func _process_power(delta: float) -> void:
	if power_out:
		return
	power -= usage() * GameConfig.POWER_DRAIN_PER_USAGE * delta
	if power <= 0.0:
		power = 0.0
		_start_power_out()
	_update_hud()


func usage() -> int:
	var u := 1
	for side: String in ["left", "right"]:
		if door_closed[side]:
			u += 1
		if light_on[side]:
			u += 1
	if monitor_up:
		u += 1
	return u


func _process_scroll(delta: float) -> void:
	if monitor_up:
		return
	var max_scroll := GameConfig.OFFICE_SIZE.x - GameConfig.VIEW_SIZE.x
	var dir := 0.0
	# Souris : plus on est près du bord, plus on tourne vite (comme FNaF).
	var mx := get_local_mouse_position().x / GameConfig.VIEW_SIZE.x
	var dz := GameConfig.OFFICE_SCROLL_DEADZONE
	if mx < 0.5 - dz:
		dir = -clampf((0.5 - dz - mx) / (0.5 - dz), 0.0, 1.0)
	elif mx > 0.5 + dz:
		dir = clampf((mx - 0.5 - dz) / (0.5 - dz), 0.0, 1.0)
	# Clavier : flèches ou Q/D, A/D.
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_Q) or Input.is_key_pressed(KEY_A):
		dir = -1.0
	elif Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		dir = 1.0
	scroll_x = clampf(scroll_x + dir * GameConfig.OFFICE_SCROLL_SPEED * delta, 0.0, max_scroll)
	world.position.x = -roundf(scroll_x)


func _process_monitor_fx(delta: float) -> void:
	if not monitor_up:
		return
	_rec_blink += delta
	rec_label.visible = fmod(_rec_blink, 1.0) < 0.6
	if _glitch_time > 0.0:
		_glitch_time -= delta
	var base := 0.22
	if current_cam in GameConfig.AUDIO_ONLY_CAMERAS:
		base = 0.35
	cam_static_mat.set_shader_parameter("intensity", 0.95 if _glitch_time > 0.0 else base)


func _unhandled_input(event: InputEvent) -> void:
	if game_finished or power_out:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE, KEY_S:
				toggle_monitor()


# =============================================================================
# Actions du joueur
# =============================================================================

func toggle_door(side: String) -> void:
	if power_out or game_finished or monitor_up:
		return
	if side_broken[side]:
		Sfx.play("door_error")
		return
	door_closed[side] = not door_closed[side]
	Sfx.play("door_close" if door_closed[side] else "door_open")
	var door: RenderSlot = doors[side]
	var target_y := 0.0 if door_closed[side] else -DOORWAY_LEFT.size.y
	create_tween().tween_property(door, "position:y", target_y, DOOR_ANIM_TIME)
	_refresh_office()


func toggle_light(side: String) -> void:
	if power_out or game_finished or monitor_up:
		return
	if side_broken[side]:
		Sfx.play("door_error")
		return
	var other := "right" if side == "left" else "left"
	light_on[other] = false
	light_on[side] = not light_on[side]
	_refresh_office()


func toggle_monitor() -> void:
	if power_out or game_finished or monitor_animating:
		return
	monitor_animating = true
	light_on["left"] = false
	light_on["right"] = false
	_refresh_office()
	var going_up := not monitor_up
	Sfx.play("cam_open" if going_up else "cam_close")
	if going_up:
		Sfx.stop("office_ambience")
	# Petite animation de « tablette » qui monte / descend (rectangle noir).
	flip_rect.visible = true
	flip_rect.position = Vector2(0, GameConfig.VIEW_SIZE.y if going_up else 0.0)
	flip_rect.size = GameConfig.VIEW_SIZE
	if not going_up:
		_set_monitor(false)
	var tw := create_tween()
	tw.tween_property(flip_rect, "position:y", 0.0 if going_up else GameConfig.VIEW_SIZE.y, MONITOR_FLIP_TIME)
	tw.tween_callback(func() -> void:
		flip_rect.visible = false
		monitor_animating = false
		if going_up:
			_set_monitor(true)
		else:
			ai.on_monitor_lowered()
	)


func _set_monitor(up: bool) -> void:
	monitor_up = up
	monitor.visible = up
	if up:
		_glitch_time = 0.15
		select_camera(current_cam, false)
		Sfx.play_loop("cam_static")
	else:
		Sfx.stop("cam_static")
		_update_ambience()
	_update_hud()


func select_camera(cam: String, with_sound: bool = true) -> void:
	if with_sound:
		# Légère variation de hauteur pour que le bruit VHS ne soit jamais identique.
		Sfx.play("cam_switch", randf_range(0.9, 1.1))
	current_cam = cam
	_glitch_time = maxf(_glitch_time, 0.12)
	for c: String in cam_buttons:
		(cam_buttons[c] as Button).set_pressed_no_signal(c == cam)
	_refresh_camera()
	_start_cam_pan()
	ai.on_camera_viewed(cam)


# =============================================================================
# Événements de l'IA
# =============================================================================

func _on_spirit_moved(who: String, from_room: String, to_room: String) -> void:
	# Brouillage si on regarde la pièce que l'esprit quitte ou rejoint (comme FNaF).
	if monitor_up and (current_cam == from_room or current_cam == to_room):
		_glitch_time = 0.8
		Sfx.play("cam_glitch")
	_refresh_camera()
	_refresh_office()


func _on_spirit_entered(who: String) -> void:
	# L'esprit est dans le bureau : les commandes de son côté ne répondent plus.
	var side: String = NightAI.DOOR_SIDE.get(who, "left")
	side_broken[side] = true
	light_on[side] = false
	_refresh_office()


func _on_joey_door_hit(drain: float) -> void:
	power = maxf(power - drain, 0.0)
	Sfx.play("door_bang")
	# Coup sur la porte : petite secousse du bureau.
	var tw := create_tween()
	for i in 6:
		tw.tween_property(world, "position:y", 8.0 if i % 2 == 0 else -8.0, 0.04)
	tw.tween_property(world, "position:y", 0.0, 0.04)
	_update_hud()


func _on_attack(who: String) -> void:
	_play_jumpscare(who)


# =============================================================================
# Panne de courant, victoire, mort
# =============================================================================

func _start_power_out() -> void:
	power_out = true
	ai.active = false
	Sfx.stop_all()
	if monitor_up:
		_set_monitor(false)
	flip_rect.visible = false
	for side: String in ["left", "right"]:
		light_on[side] = false
		if door_closed[side]:
			door_closed[side] = false
			Sfx.play("door_open")
			create_tween().tween_property(doors[side], "position:y", -DOORWAY_LEFT.size.y, DOOR_ANIM_TIME)
	darkness.visible = true
	_refresh_office()
	_update_hud()
	var delay := randf_range(GameConfig.POWER_OUT_MIN_DELAY, GameConfig.POWER_OUT_MAX_DELAY)
	get_tree().create_timer(delay).timeout.connect(func() -> void:
		if not game_finished:
			_play_jumpscare(GameConfig.POWER_OUT_KILLER)
	)


func _win_night() -> void:
	if game_finished:
		return
	game_finished = true
	ai.active = false
	Sfx.stop_all()
	SaveManager.complete_night()
	get_tree().change_scene_to_file(GameConfig.SCENE_NIGHT_WIN)


func _play_jumpscare(who: String) -> void:
	if game_finished:
		return
	game_finished = true
	ai.active = false
	Sfx.stop_all()
	# Cri propre à l'esprit s'il existe (jumpscare_<perso>.ogg), sinon le cri commun.
	Sfx.play("jumpscare_" + who if Sfx.has_file("jumpscare_" + who) else "jumpscare")
	monitor.visible = false
	flip_rect.visible = false
	darkness.visible = false
	jumpscare_slot.image_base = "jumpscares/" + who
	jumpscare_slot.placeholder_id = "jumpscare/" + who
	jumpscare_slot.visible = true
	jumpscare_slot.pivot_offset = GameConfig.VIEW_SIZE / 2
	jumpscare_slot.scale = Vector2(0.4, 0.4)
	var tw := create_tween()
	tw.tween_property(jumpscare_slot, "scale", Vector2(1.15, 1.15), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	for i in 12:
		tw.tween_property(jumpscare_slot, "position", Vector2(randf_range(-25, 25), randf_range(-25, 25)), 0.06)
	tw.tween_callback(func() -> void: get_tree().change_scene_to_file(GameConfig.SCENE_GAME_OVER))


# =============================================================================
# Rafraîchissement des visuels
# =============================================================================

func _refresh_all() -> void:
	_refresh_office()
	_refresh_camera()
	_update_hud()


func _refresh_office() -> void:
	for side: String in ["left", "right"]:
		var lit: bool = light_on[side]
		(doorway_light[side] as RenderSlot).visible = lit
		var door_room := NightAI.LEFT_DOOR if side == "left" else NightAI.RIGHT_DOOR
		for who: String in doorway_chars[side]:
			(doorway_chars[side][who] as RenderSlot).visible = lit and ai != null and ai.is_at(who, door_room)
		(door_buttons[side] as RenderSlot).state = "on" if door_closed[side] else "off"
		(light_buttons[side] as RenderSlot).state = "on" if lit else "off"
	# Bourdonnement tant qu'une lumière de couloir est allumée.
	if light_on["left"] or light_on["right"]:
		Sfx.play_loop("light_buzz")
	else:
		Sfx.stop("light_buzz")


func _refresh_camera() -> void:
	if cam_background == null:
		return
	var audio_only := current_cam in GameConfig.AUDIO_ONLY_CAMERAS
	cam_background.image_base = "cams/" + current_cam
	cam_background.placeholder_id = "cam/" + current_cam
	cam_name_label.text = "%s  %s" % [GameConfig.CAMERA_LABELS[current_cam], GameConfig.CAMERAS[current_cam]]
	audio_only_label.visible = audio_only
	for who: String in cam_chars:
		var slot: RenderSlot = cam_chars[who]
		var visible_here := false
		if ai != null and not audio_only:
			visible_here = ai.is_at(who, current_cam)
			if who == "joey" and current_cam == "cam_1c":
				visible_here = true  # la cachette montre toujours le rideau
		slot.visible = visible_here
		if visible_here:
			slot.image_base = "cams/%s_%s" % [current_cam, who]
			slot.placeholder_id = "char_cam/%s@%s" % [who, current_cam]
			slot.state = str(ai.joey_stage) if (who == "joey" and current_cam == "cam_1c") else ""
			slot.queue_redraw()


func _start_cam_pan() -> void:
	# Lent panoramique gauche ↔ droite de l'image caméra (comme FNaF).
	if _cam_pan_tween:
		_cam_pan_tween.kill()
	var max_offset := GameConfig.CAM_IMAGE_SIZE.x - GameConfig.VIEW_SIZE.x
	cam_image.position.x = 0
	_cam_pan_tween = create_tween().set_loops()
	_cam_pan_tween.tween_interval(1.0)
	_cam_pan_tween.tween_property(cam_image, "position:x", -max_offset, CAM_PAN_TIME).set_trans(Tween.TRANS_SINE)
	_cam_pan_tween.tween_interval(1.0)
	_cam_pan_tween.tween_property(cam_image, "position:x", 0.0, CAM_PAN_TIME).set_trans(Tween.TRANS_SINE)


func _update_hud() -> void:
	if time_label == null:
		return
	time_label.text = "12 AM" if hour == 0 else "%d AM" % hour
	night_label.text = "Night %d" % night
	power_label.text = "Power left: %d%%" % int(ceil(power))
	var u := 0 if power_out else usage()
	for i in usage_bars.size():
		var bar := usage_bars[i]
		bar.visible = i < u
		bar.color = Color(0.2, 0.85, 0.2) if i < 2 else (Color(0.95, 0.8, 0.1) if i < 3 else Color(0.9, 0.15, 0.1))
	cam_bar.visible = not power_out


# =============================================================================
# Construction de la scène (nœuds)
# =============================================================================

func _build() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	clip_contents = true

	# --- Monde du bureau (scrollable) ---
	world = Control.new()
	world.name = "OfficeWorld"
	world.size = GameConfig.OFFICE_SIZE
	world.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(world)
	_slot(world, "Background", Rect2(Vector2.ZERO, GameConfig.OFFICE_SIZE), "office/office", "office")

	for side: String in ["left", "right"]:
		var r := DOORWAY_LEFT if side == "left" else DOORWAY_RIGHT
		var dw := Control.new()
		dw.name = "Doorway_" + side
		dw.position = r.position
		dw.size = r.size
		dw.clip_contents = true
		dw.mouse_filter = Control.MOUSE_FILTER_IGNORE
		world.add_child(dw)
		var local := Rect2(Vector2.ZERO, r.size)
		doorway_light[side] = _slot(dw, "Light", local, "office/doorway_%s_lit" % side, "doorway_lit")
		doorway_chars[side] = {}
		var visitors: Array = ["clovis"] if side == "left" else ["paulhenri"]
		for who: String in visitors:
			doorway_chars[side][who] = _slot(dw, "Char_" + who, local, "office/doorway_%s_%s" % [side, who], "char_door/" + who)
		var door := _slot(dw, "Door", local, "office/door_" + side, "door")
		door.position.y = -r.size.y
		doors[side] = door

		var pr := PANEL_LEFT if side == "left" else PANEL_RIGHT
		var panel := _slot(world, "Panel_" + side, pr, "office/panel_" + side, "panel")
		var bx := (pr.size.x - BUTTON_SIZE.x) / 2
		door_buttons[side] = _button_slot(panel, "DoorButton", Rect2(Vector2(bx, 25), BUTTON_SIZE), "office/button_door_" + side, "button/door", toggle_door.bind(side))
		light_buttons[side] = _button_slot(panel, "LightButton", Rect2(Vector2(bx, 130), BUTTON_SIZE), "office/button_light_" + side, "button/light", toggle_light.bind(side))

	# --- Noir de la panne de courant ---
	darkness = ColorRect.new()
	darkness.name = "Darkness"
	darkness.color = Color(0, 0, 0, 0.93)
	darkness.mouse_filter = Control.MOUSE_FILTER_IGNORE
	darkness.set_anchors_preset(Control.PRESET_FULL_RECT)
	darkness.visible = false
	add_child(darkness)

	# --- Moniteur caméras ---
	monitor = Control.new()
	monitor.name = "Monitor"
	monitor.set_anchors_preset(Control.PRESET_FULL_RECT)
	monitor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	monitor.visible = false
	add_child(monitor)
	var clip := Control.new()
	clip.name = "CamClip"
	clip.clip_contents = true
	clip.size = GameConfig.VIEW_SIZE
	clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	monitor.add_child(clip)
	cam_image = Control.new()
	cam_image.name = "CamImage"
	cam_image.size = GameConfig.CAM_IMAGE_SIZE
	cam_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip.add_child(cam_image)
	var cam_rect := Rect2(Vector2.ZERO, GameConfig.CAM_IMAGE_SIZE)
	cam_background = _slot(cam_image, "Background", cam_rect, "cams/" + current_cam, "cam/" + current_cam)
	for who: String in GameConfig.CHARACTERS:
		cam_chars[who] = _slot(cam_image, "Char_" + who, cam_rect, "", "")
	cam_static = ColorRect.new()
	cam_static.name = "Static"
	cam_static.size = GameConfig.VIEW_SIZE
	cam_static.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cam_static_mat = ShaderMaterial.new()
	cam_static_mat.shader = load("res://shaders/static.gdshader")
	cam_static.material = cam_static_mat
	monitor.add_child(cam_static)
	_slot(monitor, "Frame", Rect2(Vector2.ZERO, GameConfig.VIEW_SIZE), "ui/cam_frame", "")
	audio_only_label = _label(monitor, "CAMERA DISABLED - AUDIO ONLY", Vector2(0, 300), 48, GameConfig.VIEW_SIZE.x, HORIZONTAL_ALIGNMENT_CENTER)
	rec_label = _label(monitor, "REC", Vector2(78, 28), 40, 200)
	rec_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	var dot := ColorRect.new()
	dot.color = Color(1, 0.15, 0.15)
	dot.position = Vector2(-34, 14)
	dot.size = Vector2(22, 22)
	rec_label.add_child(dot)
	cam_name_label = _label(monitor, "", Vector2(MAP_RECT.position.x, MAP_RECT.position.y - 50), 40, MAP_RECT.size.x)
	var map := _slot(monitor, "Map", MAP_RECT, "ui/map", "map")
	map.mouse_filter = Control.MOUSE_FILTER_PASS
	var group := ButtonGroup.new()
	for cam: String in GameConfig.CAMERAS:
		var b := Button.new()
		b.name = "CamButton_" + cam
		b.text = GameConfig.CAMERA_LABELS[cam]
		b.toggle_mode = true
		b.button_group = group
		b.position = GameConfig.CAMERA_MAP_POS[cam]
		b.size = Vector2(56, 34)
		b.add_theme_font_size_override("font_size", 24)
		b.add_theme_stylebox_override("normal", _box(Color(0.25, 0.25, 0.25, 0.9)))
		b.add_theme_stylebox_override("hover", _box(Color(0.4, 0.4, 0.4, 0.95)))
		b.add_theme_stylebox_override("pressed", _box(Color(0.2, 0.6, 0.2, 0.95)))
		b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		b.pressed.connect(select_camera.bind(cam))
		map.add_child(b)
		cam_buttons[cam] = b

	# --- Animation de la tablette ---
	flip_rect = ColorRect.new()
	flip_rect.name = "MonitorFlip"
	flip_rect.color = Color(0.03, 0.03, 0.03)
	flip_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flip_rect.visible = false
	add_child(flip_rect)

	# --- HUD ---
	time_label = _label(self, "12 AM", Vector2(1030, 18), 56, 220, HORIZONTAL_ALIGNMENT_RIGHT)
	night_label = _label(self, "Night 1", Vector2(1030, 72), 32, 220, HORIZONTAL_ALIGNMENT_RIGHT)
	power_label = _label(self, "Power left: 100%", Vector2(24, 610), 32, 320)
	var usage_label := _label(self, "Usage:", Vector2(24, 650), 32, 100)
	usage_label.name = "UsageLabel"
	for i in 5:
		var bar := ColorRect.new()
		bar.position = Vector2(110 + i * 26, 660)
		bar.size = Vector2(20, 30)
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(bar)
		usage_bars.append(bar)

	# --- Barre « survol pour ouvrir les caméras » ---
	cam_bar = _slot(self, "CamBar", CAM_BAR_RECT, "ui/cam_bar", "")
	cam_bar.mouse_filter = Control.MOUSE_FILTER_STOP
	if not (cam_bar as RenderSlot).has_image():
		var bg := Panel.new()
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bg.size = CAM_BAR_RECT.size
		var sb := _box(Color(1, 1, 1, 0.12))
		sb.border_color = Color(1, 1, 1, 0.8)
		sb.set_border_width_all(2)
		bg.add_theme_stylebox_override("panel", sb)
		cam_bar.add_child(bg)
		_label(cam_bar, "^^  CAMERAS  ^^", Vector2(0, 2), 32, CAM_BAR_RECT.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	cam_bar.mouse_entered.connect(func() -> void:
		if _cam_bar_armed:
			_cam_bar_armed = false
			toggle_monitor()
	)
	cam_bar.mouse_exited.connect(func() -> void: _cam_bar_armed = true)

	# --- Jumpscare (au-dessus de tout) ---
	jumpscare_slot = _slot(self, "Jumpscare", Rect2(Vector2.ZERO, GameConfig.VIEW_SIZE), "", "")
	jumpscare_slot.visible = false


func _slot(parent: Node, n: String, r: Rect2, image_base: String, placeholder: String) -> RenderSlot:
	var s := RenderSlot.new()
	s.name = n
	s.position = r.position
	s.size = r.size
	s.image_base = image_base
	s.placeholder_id = placeholder
	parent.add_child(s)
	return s


## Un bouton cliquable dont le visuel est un RenderSlot (états "on" / "off").
func _button_slot(parent: Node, n: String, r: Rect2, image_base: String, placeholder: String, action: Callable) -> RenderSlot:
	var s := _slot(parent, n, r, image_base, placeholder)
	s.state = "off"
	var b := Button.new()
	b.name = "Click"
	b.flat = true
	b.focus_mode = Control.FOCUS_NONE
	b.size = r.size
	b.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	b.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	b.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	b.pressed.connect(action)
	s.add_child(b)
	return s


func _label(parent: Node, txt: String, pos: Vector2, fsize: int, width: float, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var l := Label.new()
	l.text = txt
	l.position = pos
	l.size = Vector2(width, fsize + 8)
	l.horizontal_alignment = align
	l.add_theme_font_size_override("font_size", fsize)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l


func _box(c: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = c
	sb.border_color = Color(1, 1, 1, 0.7)
	sb.set_border_width_all(2)
	return sb
