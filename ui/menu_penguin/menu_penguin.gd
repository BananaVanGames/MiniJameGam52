class_name MenuPenguin
extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(_delta: float) -> void:
	handle_penguin_animations()


func handle_penguin_animations() -> void:
	var mouse_pos = get_global_mouse_position() + Vector2(0, 65)
	if mouse_pos.distance_to(global_position) > 5:
		animated_sprite_2d.play("walking")
	else:
		animated_sprite_2d.play("idle")


func flip_penguin_to(state: bool) -> void:
	animated_sprite_2d.flip_h = state
