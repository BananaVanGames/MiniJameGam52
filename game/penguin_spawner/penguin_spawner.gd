extends Node2D

const LETTER_POOL: Array[String] = [
	"A", "B", "C", "D", "E", "F", "G", "H",
	"I", "J", "K", "L", "M", "N", "O", "P",
	"Q", "R", "S", "T", "U", "V", "W", "X",
	"Y", "Z"
]

@export var penguin_scene: PackedScene

@export_group("Spawning")
@export var spawn_interval: float = 3.0
@export var max_simultaneous_spawns: int = 2 ## how many can spawn in the same wave
@export var spawn_distance: float = 0.0

var remaining_penguins: int = -1
var level_clear: bool = false

var _available_letters: Array[String] = []

@onready var spawner_timer: Timer = $SpawnerTimer
@onready var main_level: MainLevel = get_parent()


func _ready() -> void:
	_available_letters = LETTER_POOL.duplicate()
	spawner_timer.wait_time = spawn_interval
	get_parent().start_playing.connect(start_spawning)
	GameHandler.start_level.connect(start_spawning)


func _process(_delta: float) -> void:
	if level_clear:
		if get_tree().get_nodes_in_group("penguins").is_empty():
			main_level.end_level()
			level_clear = false


func start_spawning() -> void:
	GameHandler.level_active = true
	update_remaining_penguins()
	spawner_timer.start()


func update_remaining_penguins() -> void:
	remaining_penguins = GameHandler.get_max_level_penguins()


func stop_spawning() -> void:
	spawner_timer.stop()


func _spawn_one() -> void:
	if remaining_penguins <= 0:
		level_clear = true
		stop_spawning()
		return

	if _available_letters.is_empty():
		return

	var letter_idx: int = randi() % _available_letters.size()
	var letter: String = _available_letters[letter_idx]
	_available_letters.remove_at(letter_idx)

	var spawn_pos: Vector2 = _get_random_offscreen_position()
	var edge_pos: Vector2 = _clamp_to_edge(spawn_pos)

	_show_warning(edge_pos, letter)
	await get_tree().create_timer(1.0).timeout

	if not GameHandler.level_active:
		_return_letter(letter)
		return

	var penguin = penguin_scene.instantiate()
	penguin.set_letter(letter)
	penguin.position = spawn_pos
	penguin.tree_exited.connect(_return_letter.bind(letter))
	get_parent().add_child(penguin)
	remaining_penguins -= 1
	print("REMAINING_PENGUINS: ", remaining_penguins)


func _return_letter(letter: String) -> void:
	if letter not in _available_letters:
		_available_letters.append(letter)


func _get_random_offscreen_position() -> Vector2:
	var s: Vector2 = get_viewport_rect().size
	var d: float = spawn_distance
	match randi() % 4:
		0: return Vector2(randf_range(0, s.x), -d)
		1: return Vector2(randf_range(0, s.x), s.y + d)
		2: return Vector2(-d, randf_range(0, s.y))
		3: return Vector2(s.x + d, randf_range(0, s.y))
	return Vector2(-d, -d)


func _clamp_to_edge(pos: Vector2) -> Vector2:
	var s: Vector2 = get_viewport_rect().size
	var margin: float = 30.0
	return Vector2(clamp(pos.x, margin, s.x - margin), clamp(pos.y, margin, s.y - margin))


func _show_warning(edge_pos: Vector2, letter: String) -> void:
	var label := Label.new()
	label.text = "⚠ %s" % letter
	label.position = edge_pos + Vector2(-16, -16)
	label.add_theme_font_size_override("font_size", 16)
	label.modulate = Color.YELLOW
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0, 0, 0, 0.6)
	bg.set_corner_radius_all(4)
	bg.content_margin_left = 5; bg.content_margin_right = 5
	bg.content_margin_top = 2; bg.content_margin_bottom = 2
	label.add_theme_stylebox_override("normal", bg)
	add_child(label)
	label.z_index = 10
	var tween := create_tween().set_loops(3)
	tween.tween_property(label, "modulate:a", 0.2, 0.15)
	tween.tween_property(label, "modulate:a", 1.0, 0.15)
	await get_tree().create_timer(1.0).timeout
	label.queue_free()


func _on_spawner_timer_timeout() -> void:
	if not GameHandler.level_active:
		return

	var active_count: int = get_tree().get_nodes_in_group("penguins").size()
	var slots_free: int = GameHandler.max_screen_penguins - active_count

	if slots_free <= 0 or _available_letters.is_empty():
		return

	var to_spawn: int = mini(max_simultaneous_spawns, slots_free)
	to_spawn = mini(to_spawn, _available_letters.size())

	for _i in to_spawn:
		_spawn_one()
