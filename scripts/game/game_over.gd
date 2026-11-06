extends Control
## Écran de mort (après le jumpscare) : neige + « GAME OVER », retour au menu.
## Fond remplaçable : assets/renders/ui/game_over.png
## « Continue » reprendra la même nuit.

const DURATION := 6.0

var _done := false
var _shown_at := 0


func _ready() -> void:
	_shown_at = Time.get_ticks_msec()
	var bg := RenderSlot.new()
	bg.size = GameConfig.VIEW_SIZE
	bg.image_base = "ui/game_over"
	add_child(bg)
	var noise := ColorRect.new()
	noise.size = GameConfig.VIEW_SIZE
	var mat := ShaderMaterial.new()
	mat.shader = load("res://shaders/static.gdshader")
	mat.set_shader_parameter("intensity", 0.9)
	noise.material = mat
	add_child(noise)
	var tw := create_tween()
	tw.tween_method(func(v: float) -> void: mat.set_shader_parameter("intensity", v), 1.0, 0.25, 2.0)
	var l := Label.new()
	l.text = "GAME OVER"
	l.size = Vector2(GameConfig.VIEW_SIZE.x, 120)
	l.position = Vector2(0, GameConfig.VIEW_SIZE.y - 180)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 96)
	add_child(l)
	var sub := Label.new()
	sub.text = "Night %d" % SaveManager.playing_night
	sub.size = Vector2(GameConfig.VIEW_SIZE.x, 40)
	sub.position = Vector2(0, GameConfig.VIEW_SIZE.y - 70)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(sub)
	get_tree().create_timer(DURATION).timeout.connect(_back)


func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton or event is InputEventKey) and event.pressed:
		# On laisse au moins 1,5 s d'écran avant de pouvoir passer.
		if Time.get_ticks_msec() - _shown_at > 1500:
			_back()


func _back() -> void:
	if _done:
		return
	_done = true
	get_tree().change_scene_to_file(GameConfig.SCENE_MENU)
