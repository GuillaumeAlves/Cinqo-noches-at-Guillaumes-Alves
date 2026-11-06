extends Control
## Écran de fin après la nuit 5 (texte provisoire, à remplacer par le vrai lore).
## Fond remplaçable : assets/renders/ui/ending.png

var _done := false
var _shown_at := 0


func _ready() -> void:
	_shown_at = Time.get_ticks_msec()
	var bg := RenderSlot.new()
	bg.size = GameConfig.VIEW_SIZE
	bg.image_base = "ui/ending"
	add_child(bg)
	var l := Label.new()
	l.text = "5 nuits survécues.\n\nGuillaume Alves vous remercie pour votre travail.\n(ou pas)\n\n[ fin provisoire ]"
	l.size = GameConfig.VIEW_SIZE
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 44)
	add_child(l)
	get_tree().create_timer(10.0).timeout.connect(_back)


func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton or event is InputEventKey) and event.pressed and Time.get_ticks_msec() - _shown_at > 2000:
		_back()


func _back() -> void:
	if _done:
		return
	_done = true
	get_tree().change_scene_to_file(GameConfig.SCENE_MENU)
