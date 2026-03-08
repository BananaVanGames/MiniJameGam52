extends Node2D

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D


func _ready() -> void:
	GameHandler.get_platform_positions.connect(on_requested_random_positions)


func on_requested_random_positions(qtt_positions: int) -> void:
	var values: Array

	for i in qtt_positions:
		values.append(get_random_platform_position())

	GameHandler.set_random_platform_positions(values)


func get_random_platform_position() -> Vector2:
	var rect: Rect2 = collision_shape_2d.shape.get_rect()
	var x = randi_range(int(rect.position.x), int(rect.position.x + rect.size.x))
	var y = randi_range(int(rect.position.y), int(rect.position.y + rect.size.y))
	var rand_point = global_position + Vector2(x, y)
	return rand_point
