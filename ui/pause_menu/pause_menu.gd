extends Control

const PIP = preload("uid://bg66rd8xs1bie")
const PUP = preload("uid://xvk4jkqkwkth")

var hovered_button: Button = null
var time: float = 0.0

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var resume: Button = $Menu/Control/Resume
@onready var quit: Button = $Menu/Control4/Quit


func _ready() -> void:
	resume.mouse_entered.connect(_on_any_button_mouse_entered.bind(resume))
	quit.mouse_entered.connect(_on_any_button_mouse_entered.bind(quit))

	resume.mouse_exited.connect(_on_any_button_mouse_exited.bind(resume))
	quit.mouse_exited.connect(_on_any_button_mouse_exited.bind(quit))


func _process(delta: float) -> void:
	handle_hover_button_behaviour(delta)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("Esc"):
		if get_tree().paused:
			get_tree().set_pause(false)
			visible = false
		else:
			get_tree().set_pause(true)
			visible = true


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


func _on_quit_pressed() -> void:
	audio_stream_player.stream = PUP
	audio_stream_player.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().set_pause(false)
	visible = false
	SceneLoader.load_scene("uid://6n3h48sf0yhd")


func _on_resume_pressed() -> void:
	audio_stream_player.stream = PIP
	audio_stream_player.play()
	visible = false
	get_tree().paused = false
