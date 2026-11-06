extends Control
## Menu d'accueil — écran noir, titre en haut, boutons en bas à gauche.
## Au survol de la souris, un ">> " apparaît devant le texte (comme dans FNaF).
## New Game → nuit 1 · Continue → nuit sauvegardée · Settings → rien pour l'instant.
## Fond remplaçable : assets/renders/ui/menu.png

const HOVER_PREFIX: String = ">> "

@onready var _buttons: Array[Button] = [
	$MenuButtons/NewGameButton,
	$MenuButtons/ContinueButton,
	$MenuButtons/SettingsButton,
]
@onready var _continue_night: Label = $ContinueNight
@onready var _stars: Label = $Stars


func _ready() -> void:
	var bg := RenderSlot.new()
	bg.name = "MenuRender"
	bg.size = GameConfig.VIEW_SIZE
	bg.image_base = "ui/menu"
	add_child(bg)
	move_child(bg, 1)  # juste au-dessus du fond noir, sous le texte
	for button: Button in _buttons:
		button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
		button.mouse_exited.connect(_on_button_mouse_exited.bind(button))
		button.pressed.connect(_on_button_pressed.bind(button))
	_continue_night.text = "Night %d" % SaveManager.current_night
	_stars.visible = SaveManager.game_completed


func _on_button_mouse_entered(button: Button) -> void:
	if not button.text.begins_with(HOVER_PREFIX):
		button.text = HOVER_PREFIX + button.text
	if button.name == "ContinueButton":
		_continue_night.visible = true


func _on_button_mouse_exited(button: Button) -> void:
	if button.text.begins_with(HOVER_PREFIX):
		button.text = button.text.trim_prefix(HOVER_PREFIX)
	if button.name == "ContinueButton":
		_continue_night.visible = false


func _on_button_pressed(button: Button) -> void:
	match button.name:
		"NewGameButton":
			SaveManager.start_new_game()
		"ContinueButton":
			SaveManager.continue_game()
		"SettingsButton":
			pass  # Pas encore de réglages.
