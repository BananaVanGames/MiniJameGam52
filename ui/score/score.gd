extends Control

@onready var label: Label = $Label

func _ready() -> void:
	_update()
	GameHandler.score_changed.connect(_on_score_changed)

func _update() -> void:
	label.text = "%d / %d" % [GameHandler.score_points, GameHandler.max_score_points]

func _on_score_changed(current: int, max_score: int) -> void:
	label.text = "%d / %d" % [current, max_score]
