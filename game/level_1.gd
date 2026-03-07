extends Node2D

const LEVEL_INTRO = preload("uid://b0uyfgf0cf1qr")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameHandler.load_level(LevelData.LEVELS[1])
	GameHandler.start_level()
	var intro = LEVEL_INTRO.instantiate()
	add_child(intro)
	intro.intro_finished.connect(on_intro_finished)


func _process(delta: float) -> void:
	pass


func on_intro_finished() -> void:
	pass
