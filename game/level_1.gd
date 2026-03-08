class_name MainLevel
extends Node2D

signal start_playing

const LEVEL_INTRO = preload("uid://b0uyfgf0cf1qr")
const END_SCREEN = preload("uid://ctotp755d0e3a")


@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var pause_menu: Control = $CanvasLayer/PauseMenu
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var platform: Node2D = $Platform

var _music_position: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameHandler.whistle_blown.connect(_on_whistle_blown)
	GameHandler.penguins_delivered.connect(_on_penguins_delivered)
	GameHandler.load_level(LevelData.LEVELS[1])
	print(GameHandler.max_level_penguins)
	GameHandler.start_level()
	var intro = LEVEL_INTRO.instantiate()
	canvas_layer.add_child(intro)
	intro.intro_finished.connect(on_intro_finished)

func _on_whistle_blown() -> void:
	if get_tree().get_nodes_in_group("penguins").is_empty():
		return
	_music_position = audio_stream_player.get_playback_position()
	audio_stream_player.stream = load("res://sound/music/penguin music run.ogg")
	audio_stream_player.play()
	platform.platform_on_whistle_blown()
	
func _on_penguins_delivered() -> void:
	audio_stream_player.stream = load("res://sound/music/penguin music.ogg")
	audio_stream_player.play(_music_position)
	platform.platform_on_delivered()

func on_intro_finished() -> void:
	start_playing.emit()


func end_level() -> void:
	var end_screen = END_SCREEN.instantiate()
	canvas_layer.add_child(end_screen)
