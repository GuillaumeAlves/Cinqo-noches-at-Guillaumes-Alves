extends Control
## Menu d'accueil — écran noir, titre en haut, boutons en bas à gauche.
## Les boutons ne font rien pour l'instant (aucune autre scène).
## Au survol de la souris, un ">> " apparaît devant le texte (comme dans FNaF).

const HOVER_PREFIX: String = ">> "

@onready var _buttons: Array[Button] = [
	$MenuButtons/NewGameButton,
	$MenuButtons/ContinueButton,
	$MenuButtons/SettingsButton,
]


func _ready() -> void:
	for button: Button in _buttons:
		button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
		button.mouse_exited.connect(_on_button_mouse_exited.bind(button))
		# Les boutons ne font rien pour l'instant : on consomme le clic
		# pour éviter tout comportement par défaut.
		button.pressed.connect(_on_button_pressed.bind(button))


func _on_button_mouse_entered(button: Button) -> void:
	if not button.text.begins_with(HOVER_PREFIX):
		button.text = HOVER_PREFIX + button.text


func _on_button_mouse_exited(button: Button) -> void:
	if button.text.begins_with(HOVER_PREFIX):
		button.text = button.text.trim_prefix(HOVER_PREFIX)


func _on_button_pressed(_button: Button) -> void:
	# Volontairement vide : aucune autre scène pour l'instant.
	pass
