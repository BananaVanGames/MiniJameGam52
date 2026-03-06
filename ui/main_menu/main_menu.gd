extends Control

@export var menu: VBoxContainer
@export var main_settings: VBoxContainer
@export var video_settings: VBoxContainer
@export var audio_settings: VBoxContainer
@export var back_button: Button

@export var scoreboard_button: Button
@export var settings_button: Button
@export var video_button: Button
@export var audio_button: Button

var nav_stack: Array[Control] = []
var current_panel: Control = null
var hovered_button: Button = null
var time: float = 0.0

@onready var start: Button = $Menu/Control/Start
@onready var scoreboard: Button = $Menu/Control2/Scoreboard
@onready var settings: Button = $Menu/Control3/Settings
@onready var quit: Button = $Menu/Control4/Quit


func _ready():
	current_panel = menu
	_show_panel(menu)
	_update_back_button()

	back_button.pressed.connect(_on_back_pressed)
	#scoreboard_button.connect(_navigate_to(scoreboard))
	settings_button.pressed.connect(_navigate_to.bind(main_settings))
	video_button.pressed.connect(_navigate_to.bind(video_settings))
	audio_button.pressed.connect(_navigate_to.bind(audio_settings))

	start.mouse_entered.connect(_on_any_button_mouse_entered.bind(start))
	scoreboard.mouse_entered.connect(_on_any_button_mouse_entered.bind(scoreboard))
	settings.mouse_entered.connect(_on_any_button_mouse_entered.bind(settings))
	quit.mouse_entered.connect(_on_any_button_mouse_entered.bind(quit))

	start.mouse_exited.connect(_on_any_button_mouse_exited.bind(start))
	scoreboard.mouse_exited.connect(_on_any_button_mouse_exited.bind(scoreboard))
	settings.mouse_exited.connect(_on_any_button_mouse_exited.bind(settings))
	quit.mouse_exited.connect(_on_any_button_mouse_exited.bind(quit))


func _process(delta: float) -> void:
	if hovered_button:
		time += delta
		var pulse = 1.0 + sin(time * 4.0) * 0.1
		hovered_button.scale = Vector2(pulse, pulse)
	else:
		time = 0.0


func _on_any_button_mouse_entered(button) -> void:
	hovered_button = button


func _on_any_button_mouse_exited(button) -> void:
	if hovered_button == button:
		hovered_button.scale = Vector2.ONE
		hovered_button = null


func _show_panel(panel: Control):
	panel.visible = true


func _update_back_button():
	back_button.visible = nav_stack.size() > 0


func _navigate_to(panel: Control):
	if current_panel:
		nav_stack.append(current_panel)
		current_panel.visible = false

	current_panel = panel
	_show_panel(current_panel)
	_update_back_button()


func _on_back_pressed():
	if nav_stack.is_empty():
		return

	current_panel.visible = false
	current_panel = nav_stack.pop_back()
	_show_panel(current_panel)
	_update_back_button()


func _on_quit_pressed():
	get_tree().quit()


func _on_start_pressed() -> void:
	SceneLoader.load_scene("uid://d1gglgt76yt1s")
