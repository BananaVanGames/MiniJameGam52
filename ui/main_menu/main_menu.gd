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

var speed: float = 100.0
var flip = {
	"LEFT": false,
	"RIGHT": true,
}

@onready var start: Button = $Menu/Control/Start
@onready var settings: Button = $Menu/Control3/Settings
@onready var quit: Button = $Menu/Control4/Quit
@onready var video: Button = $Settings/Control/Video
@onready var audio: Button = $Settings/Control2/Audio
@onready var back: Button = $Back
@onready var menu_penguin: MenuPenguin = $MenuPenguin
@onready var whistle: Node2D = $CanvasLayer/Whistle
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

const PIP = preload("uid://bg66rd8xs1bie")
const PUP = preload("uid://xvk4jkqkwkth")

func _ready():
	current_panel = menu
	_show_panel(menu)
	_update_back_button()

	back_button.pressed.connect(_on_back_pressed)
	settings_button.pressed.connect(_navigate_to.bind(main_settings))
	video_button.pressed.connect(_navigate_to.bind(video_settings))
	audio_button.pressed.connect(_navigate_to.bind(audio_settings))

	start.mouse_entered.connect(_on_any_button_mouse_entered.bind(start))
	settings.mouse_entered.connect(_on_any_button_mouse_entered.bind(settings))
	quit.mouse_entered.connect(_on_any_button_mouse_entered.bind(quit))
	video.mouse_entered.connect(_on_any_button_mouse_entered.bind(video))
	audio.mouse_entered.connect(_on_any_button_mouse_entered.bind(audio))
	back.mouse_entered.connect(_on_any_button_mouse_entered.bind(back))

	start.mouse_exited.connect(_on_any_button_mouse_exited.bind(start))
	settings.mouse_exited.connect(_on_any_button_mouse_exited.bind(settings))
	quit.mouse_exited.connect(_on_any_button_mouse_exited.bind(quit))
	video.mouse_exited.connect(_on_any_button_mouse_exited.bind(video))
	audio.mouse_exited.connect(_on_any_button_mouse_exited.bind(audio))
	back.mouse_exited.connect(_on_any_button_mouse_exited.bind(back))


func _process(delta: float) -> void:
	handle_hover_button_behaviour(delta)
	handle_following_penguin(delta)

	if video_settings.visible:
		video_settings.entered_video = true
	if audio_settings.visible:
		audio_settings.entered_audio = true


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("Esc"):
		if _on_back_pressed():
			_on_quit_pressed()


func handle_following_penguin(delta: float) -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	if mouse_pos < menu_penguin.global_position:
		menu_penguin.flip_penguin_to(flip["LEFT"])
	elif mouse_pos > menu_penguin.global_position:
		menu_penguin.flip_penguin_to(flip["RIGHT"])

	var new_pos = menu_penguin.global_position.move_toward(Vector2(mouse_pos.x, mouse_pos.y + 65), speed * delta)
	var viewport_size = get_viewport_rect().size
	var margin := 100.0

	new_pos.x = clamp(new_pos.x, -margin, viewport_size.x + margin)
	new_pos.y = clamp(new_pos.y, -margin, viewport_size.y + margin)

	menu_penguin.global_position = new_pos


func handle_hover_button_behaviour(delta: float) -> void:
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


func _show_panel(panel: Control) -> void:
	panel.visible = true


func _update_back_button() -> void:
	back_button.visible = nav_stack.size() > 0


func _navigate_to(panel: Control) -> void:
	audio_stream_player.stream = PIP
	audio_stream_player.play()
	if current_panel:
		nav_stack.append(current_panel)
		current_panel.visible = false

	current_panel = panel
	_show_panel(current_panel)
	_update_back_button()


func _on_back_pressed() -> bool:
	audio_stream_player.stream = PUP
	audio_stream_player.play()
	if nav_stack.is_empty():
		return true

	current_panel.visible = false
	current_panel = nav_stack.pop_back()
	_show_panel(current_panel)
	_update_back_button()
	if not back_button.visible:
		print("SETTINGS SAVED")
		SettingsManager.save_settings(
			video_settings.get_video_settings(), audio_settings.get_audio_settings()
		)
	return false


func _on_quit_pressed() -> void:
	audio_stream_player.stream = PUP
	audio_stream_player.play()
	await get_tree().create_timer(1.5).timeout
	get_tree().quit()


func _on_start_pressed() -> void:
	whistle.blow_whistle()
	await get_tree().create_timer(1.5).timeout
	SceneLoader.load_scene("uid://7oew5x4hq6kt")
