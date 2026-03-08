class_name MainLevel
extends Node2D

signal start_playing

const LEVEL_INTRO = preload("uid://b0uyfgf0cf1qr")
const END_SCREEN = preload("uid://ctotp755d0e3a")

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var pause_menu: Control = $CanvasLayer/PauseMenu


func _ready() -> void:
	GameHandler.load_level(LevelData.LEVELS[1])
	GameHandler.reset_level_parameters()
	var intro = LEVEL_INTRO.instantiate()
	canvas_layer.add_child(intro)
	intro.intro_finished.connect(on_intro_finished)


func on_intro_finished() -> void:
	start_playing.emit()


func end_level() -> void:
	var end_screen = END_SCREEN.instantiate()
	canvas_layer.add_child(end_screen)
