class_name MainLevel
extends Node2D

signal start_playing

const LEVEL_INTRO = preload("uid://b0uyfgf0cf1qr")
const END_SCREEN = preload("uid://ctotp755d0e3a")
const LEVEL_INTRO_MUSIC = preload("uid://bd6nxbpyrnox4")
const PENGUIN_MUSIC = preload("uid://cuc8bor1dge2r")
const BACKGROUND_1 = preload("uid://y27ks8awrntc")
const BACKGROUND_2 = preload("uid://cp18b3vygjgm8")
const BACKGROUND_3 = preload("uid://bxgk5c5h3056n")

const BACKGROUNDS = {
	"BACKGROUND_1": BACKGROUND_1,
	"BACKGROUND_2": BACKGROUND_2,
	"BACKGROUND_3": BACKGROUND_3,
}

var tutorial_finished: bool = false

var _music_position: float = 0.0

@onready var background: Control = $Background

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var pause_menu: Control = $CanvasLayer/PauseMenu
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var platform: Node2D = $Platform
@onready var tutorial: Control = $CanvasLayer/Tutorial
@onready var whistle: Whistle = $CanvasLayer/Whistle


func _ready() -> void:
	tutorial.tutorial_finished.connect(_on_tutorial_finished)

	GameHandler.start_level.connect(_on_starting_level)
	GameHandler.whistle_blown.connect(_on_whistle_blown)
	GameHandler.penguins_delivered.connect(_on_penguins_delivered)
	GameHandler.load_level(LevelData.LEVELS[1])
	GameHandler.reset_level_parameters()


func on_intro_finished() -> void:
	start_playing.emit()
	audio_stream_player.stream = PENGUIN_MUSIC
	audio_stream_player.play()
	whistle.start_global_timer()

	var bostezo_timer = Timer.new()
	add_child(bostezo_timer)
	var delay = randf_range(2, 7)
	bostezo_timer.start(delay)

	var bostezo_player = AudioStreamPlayer.new()
	add_child(bostezo_player)
	bostezo_player.stream = load("uid://bmy0ghoar7h5d")

	bostezo_timer.timeout.connect(func():
			bostezo_player.play()
			await bostezo_player.finished
			bostezo_player.queue_free()
			bostezo_timer.queue_free()
	)


func end_level() -> void:
	whistle.stop_global_timer()

	var end_screen = END_SCREEN.instantiate()
	canvas_layer.add_child(end_screen)

	if GameHandler.level_number < 3:
		var bg_children = background.get_children()
		for i in bg_children:
			i.queue_free()

		var new_bg_name: String = "BACKGROUND_" + str(GameHandler.level_number + 1)
		var new_bg = BACKGROUNDS[new_bg_name]
		new_bg = new_bg.instantiate()
		background.add_child(new_bg)


func _on_starting_level() -> void:
	whistle.start_global_timer()


func _on_tutorial_finished() -> void:
	tutorial_finished = true
	tutorial.queue_free()

	var intro = LEVEL_INTRO.instantiate()
	canvas_layer.add_child(intro)

	intro.intro_finished.connect(on_intro_finished)
	audio_stream_player.stream = LEVEL_INTRO_MUSIC
	audio_stream_player.play()


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
