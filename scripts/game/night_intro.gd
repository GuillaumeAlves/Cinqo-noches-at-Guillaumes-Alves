extends Control
## Écran « 12:00 AM / Night N » avant chaque nuit (comme FNaF).
## Fond remplaçable : assets/renders/ui/night_intro.png

const DURATION := 3.0


func _ready() -> void:
	var night := SaveManager.playing_night
	var bg := RenderSlot.new()
	bg.size = GameConfig.VIEW_SIZE
	bg.image_base = "ui/night_intro"
	add_child(bg)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.size = Vector2(600, 200)
	box.position = (GameConfig.VIEW_SIZE - box.size) / 2
	add_child(box)
	for t: Array in [["12:00 AM", 72], ["Night %d" % night, 56]]:
		var l := Label.new()
		l.text = t[0]
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.add_theme_font_size_override("font_size", t[1])
		box.add_child(l)
	box.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(box, "modulate:a", 1.0, 0.6)
	tw.tween_interval(DURATION - 1.2)
	tw.tween_property(box, "modulate:a", 0.0, 0.6)
	tw.tween_callback(func() -> void: get_tree().change_scene_to_file(GameConfig.SCENE_OFFICE))
