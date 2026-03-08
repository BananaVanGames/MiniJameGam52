extends Control

signal tutorial_finished
@onready var label: Label = $Label

var _can_input: bool = false

func _ready() -> void:
	# Pulse animation on the label
	var tween := create_tween().set_loops()
	tween.tween_property(label, "modulate:a", 0.1, 0.6)
	tween.tween_property(label, "modulate:a", 1.0, 0.6)

	# Short delay before accepting input so it doesn't skip instantly
	await get_tree().create_timer(0.5).timeout
	_can_input = true

func _input(event: InputEvent) -> void:
	if not _can_input:
		return
	if event is InputEventKey and event.pressed and not event.echo or event is InputEventMouseButton and event.pressed:
		_can_input = false
		tutorial_finished.emit()
