extends Node2D

signal start_playing

const LEVEL_INTRO = preload("uid://b0uyfgf0cf1qr")

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var pause_menu: Control = $CanvasLayer/PauseMenu


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameHandler.load_level(LevelData.LEVELS[1])
	GameHandler.start_level()
	var intro = LEVEL_INTRO.instantiate()
	canvas_layer.add_child(intro)
	intro.intro_finished.connect(on_intro_finished)


func on_intro_finished() -> void:
	start_playing.emit()
