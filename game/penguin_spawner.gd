# PenguinSpawner.gd
# Attach to: Node2D in your main scene. No child nodes needed — everything is generated here.

extends Node2D

@export var penguin_scene: PackedScene

@export_group("Spawn Points")
@export var points_per_edge: int = 3
@export var edge_inset: float    = 40.0

@export_group("Spawning")
@export var spawn_interval: float = 3.0
@export var max_penguins: int     = 8

const LETTER_POOL: Array[String] = [
	"A","B","C","D","E","F","G","H",
	"I","J","K","L","M","N","O","P",
	"Q","R","S","T","U","V","W","X",
	"Y","Z"
]

var _available_letters: Array[String] = []
var _spawn_positions: Array[Vector2]  = []   # just positions, nothing more
var _debug_labels: Array[Label]       = []   # one Label per spawn position

# ─────────────────────────────────────────────
func _ready() -> void:
	_available_letters = LETTER_POOL.duplicate()
	_generate_spawn_points()

	var t := Timer.new()
	t.wait_time = spawn_interval
	t.autostart = true
	t.one_shot  = false
	t.timeout.connect(_on_spawn_timer)
	add_child(t)

# ─────────────────────────────────────────────
func _generate_spawn_points() -> void:
	var W: float = get_viewport_rect().size.x
	var H: float = get_viewport_rect().size.y

	for i in range(1, points_per_edge + 1):
		var t: float = float(i) / float(points_per_edge + 1)
		_spawn_positions.append(Vector2(W * t,        edge_inset))      # top
		_spawn_positions.append(Vector2(W * t,        H - edge_inset))  # bottom
		_spawn_positions.append(Vector2(edge_inset,   H * t))           # left
		_spawn_positions.append(Vector2(W - edge_inset, H * t))         # right

	# Create one debug Label per position — owned by this node
	for pos in _spawn_positions:
		var label := Label.new()
		label.position = pos + Vector2(-12, -24)
		label.text = "[ ]"
		label.add_theme_font_size_override("font_size", 13)
		var bg := StyleBoxFlat.new()
		bg.bg_color = Color(0, 0, 0, 0.5)
		bg.set_corner_radius_all(3)
		bg.content_margin_left = 4; bg.content_margin_right = 4
		bg.content_margin_top = 2;  bg.content_margin_bottom = 2
		label.add_theme_stylebox_override("normal", bg)
		add_child(label)
		_debug_labels.append(label)

# ─────────────────────────────────────────────
func _on_spawn_timer() -> void:
	if get_tree().get_nodes_in_group("penguins").size() >= max_penguins:
		return
	if _available_letters.is_empty():
		return

	var letter_idx: int    = randi() % _available_letters.size()
	var letter: String     = _available_letters[letter_idx]
	_available_letters.remove_at(letter_idx)

	var pos_idx: int       = randi() % _spawn_positions.size()
	var spawn_pos: Vector2 = _spawn_positions[pos_idx]

	var penguin = penguin_scene.instantiate()
	penguin.set_letter(letter)
	penguin.position = spawn_pos
	penguin.tree_exited.connect(_return_letter.bind(letter))
	get_parent().add_child(penguin)

	# Flash the label at that position
	_debug_labels[pos_idx].text     = "[%s]" % letter
	_debug_labels[pos_idx].modulate = Color.YELLOW
	await get_tree().create_timer(0.5).timeout
	_debug_labels[pos_idx].text     = "[ ]"
	_debug_labels[pos_idx].modulate = Color.WHITE

func _return_letter(letter: String) -> void:
	if letter not in _available_letters:
		_available_letters.append(letter)
