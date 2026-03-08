extends Control

signal intro_finished

enum steps {
	READY,
	SET,
	FREEZE,
	FREE,
}

@export var initial_time: float = 0.75
@export var step_time: float = 0.75

var current_step: steps = steps.READY
var color_rect_opacity = [1, 1, 0.8, 0.4, 0]
var step := 1

@onready var timer: Timer = $Timer
@onready var labels: Array[Label] = [
	$Ready,
	$Set,
	$"Freeze!"
]
@onready var color_rect: ColorRect = $ColorRect


func _ready() -> void:
	timer.start(initial_time)


func _on_timer_timeout() -> void:
	if step < labels.size():
		if step > 0:
			labels[step - 1].visible = false

		labels[step].visible = true
		step += 1
		color_rect.color.a = color_rect_opacity[step]
		timer.start(step_time)
	else:
		await get_tree().create_timer(1).timeout
		intro_finished.emit()
		queue_free()
