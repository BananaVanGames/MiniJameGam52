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


func _ready() -> void:
	tutorial.tutorial_finished.connect(_on_tutorial_finished)

	GameHandler.whistle_blown.connect(_on_whistle_blown)
	GameHandler.penguins_delivered.connect(_on_penguins_delivered)
	GameHandler.load_level(LevelData.LEVELS[1])
	GameHandler.reset_level_parameters()

	audio_stream_player.stream = LEVEL_INTRO_MUSIC
	audio_stream_player.play()


func on_intro_finished() -> void:
	start_playing.emit()
	audio_stream_player.stream = PENGUIN_MUSIC
	audio_stream_player.play()


func end_level() -> void:
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


func _on_tutorial_finished() -> void:
	tutorial_finished = true

	tutorial.queue_free()
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
