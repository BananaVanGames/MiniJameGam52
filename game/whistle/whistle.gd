extends Node2D

const WHISTLE_1 = preload("uid://dwu1j4aacffsm")
const WHISTLE_2 = preload("uid://ddafy6ighwblf")
const WHISTLE_3 = preload("uid://obcflc0rqhme")
const WHISTLE_SOUNDS = [WHISTLE_1, WHISTLE_2, WHISTLE_3]

@export var global_time: float = 10

var mouse_hovering: bool = false
var time: float = 0.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var global_timer: Timer = $GlobalTimer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	global_timer.wait_time = global_time
	GameHandler.whistle_blown.connect(_on_global_timer_timeout)


func _process(delta: float) -> void:
	if mouse_hovering:
		time += delta
		var pulse = 1.0 + sin(time * 4.0) * 0.1
		animated_sprite_2d.scale = Vector2(pulse, pulse)
	else:
		time = 0.0


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("Space"):
		if GameHandler.level_active:
			GameHandler.whistle_blown.emit()


func blow_whistle() -> void:
	audio_stream_player.stream = WHISTLE_SOUNDS.pick_random()
	audio_stream_player.play()

	animation_player.stop()
	animation_player.play("blow")


func _on_global_timer_timeout() -> void:
	blow_whistle()

	if GameHandler.level_active:
		global_timer.stop()
		global_timer.start(global_time)
		GameHandler.send_penguins_to_platform()


func _on_texture_button_pressed() -> void:
	GameHandler.whistle_blown.emit()


func _on_texture_button_mouse_entered() -> void:
	mouse_hovering = true


func _on_texture_button_mouse_exited() -> void:
	mouse_hovering = false
