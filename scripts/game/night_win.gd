extends Control
## Écran de victoire de nuit : « 5 AM » qui roule vers « 6 AM » (comme FNaF).
## Fond remplaçable : assets/renders/ui/night_win.png
## Ensuite : nuit suivante, ou écran de fin après la nuit 5.

const ROLL_TIME := 1.6
const HOLD_TIME := 3.0

var _digit_box: Control


func _ready() -> void:
	var bg := RenderSlot.new()
	bg.size = GameConfig.VIEW_SIZE
	bg.image_base = "ui/night_win"
	add_child(bg)
	# Le chiffre défile de 5 à 6 dans une fenêtre masquée.
	var row := Control.new()
	row.size = Vector2(400, 140)
	row.position = (GameConfig.VIEW_SIZE - row.size) / 2
	add_child(row)
	_digit_box = Control.new()
	_digit_box.clip_contents = true
	_digit_box.size = Vector2(90, 130)
	_digit_box.position = Vector2(60, 0)
	row.add_child(_digit_box)
	var digits := Control.new()
	_digit_box.add_child(digits)
	for i in 2:
		var d := _big_label(str(5 + i))
		d.position = Vector2(0, i * 130)
		d.size = Vector2(90, 130)
		digits.add_child(d)
	var am := _big_label("AM")
	am.position = Vector2(150, 0)
	am.size = Vector2(200, 130)
	row.add_child(am)
	var tw := create_tween()
	tw.tween_interval(0.8)
	tw.tween_property(digits, "position:y", -130.0, ROLL_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tw.tween_interval(HOLD_TIME)
	tw.tween_callback(_next)


func _big_label(t: String) -> Label:
	var l := Label.new()
	l.text = t
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 128)
	return l


func _next() -> void:
	if SaveManager.playing_night >= GameConfig.LAST_NIGHT:
		get_tree().change_scene_to_file(GameConfig.SCENE_ENDING)
	else:
		SaveManager.start_night(SaveManager.playing_night + 1)
