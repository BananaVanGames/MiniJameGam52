extends Control

const MAIN_MENU = preload("uid://6n3h48sf0yhd")

var hovered_button: Button = null
var time: float = 0.0

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
	GameHandler.player_blows_whistle()
	await get_tree().create_timer(1.5).timeout
	get_tree().set_pause(false)
	visible = false
	get_tree().change_scene_to_packed(MAIN_MENU)


func _on_resume_pressed() -> void:
	visible = false
	get_tree().paused = false
