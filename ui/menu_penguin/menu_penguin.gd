class_name MenuPenguin
extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.play("walking")


func flip_penguin_to(state: bool) -> void:
	animated_sprite_2d.flip_h = state
