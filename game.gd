extends Node2D

var counter: float = 0


func _ready():
	print("VIEWPORT SIZE: ", get_viewport_rect().size)


func spawn_penguin() -> void:
	print("SPAWNING PENGUIN AT: ", get_random_position_off_screen())


#REVISA 
func get_random_position_off_screen():
	var randx
	var randy
	var distance_outside_screen := 100
	var screensize

	# Globals.camera doesn't exist when testing scene

	screensize = get_viewport_rect().size

	var rng := RandomNumberGenerator.new()
	rng.randomize()

	if rng.randi() % 2 == 0:
		# spawn at top or bottom
		randx = int(rng.randi_range(0, screensize.x))
		randy = -distance_outside_screen if rng.randi() % 2 == 0 else screensize.y + distance_outside_screen
	else:
		# spawn at left or right
		randy = int(rng.randi_range(0, screensize.y))
		randx = -distance_outside_screen if rng.randi() % 2 == 0 else screensize.x + distance_outside_screen

	return Vector2(randx, randy)


func _on_spawn_timer_timeout() -> void:
	spawn_penguin()
