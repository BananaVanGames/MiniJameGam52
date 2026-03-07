extends Control

signal intro_finished

enum steps {
	READY,
	SET,
	FREEZE,
}

@export var initial_time: float = 0.75
@export var step_time: float = 0.5

var current_step = steps.READY

@onready var timer: Timer = $Timer
@onready var ready_label: Label = $Ready
@onready var set_label: Label = $Set
@onready var freeze_label: Label = $"Freeze!"


func _ready() -> void:
	timer.start(initial_time)


func _on_timer_timeout() -> void:
	timer.start(step_time)
	match(current_step):
		steps.READY:
			ready_label.visible = false
			set_label.visible = true
			current_step = steps.SET
		steps.SET:
			set_label.visible = false
			freeze_label.visible = true
			current_step = steps.FREEZE
		steps.FREEZE:
			freeze_label.visible = false
		_: 
			intro_finished.emit()
			queue_free()
