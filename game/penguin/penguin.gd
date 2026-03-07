extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var dir_timer: Timer = $DirTimer
@onready var temp_timer: Timer = $TempTimer
@onready var letter_label: Label = $LetterLabel
@onready var temp_bar: ProgressBar = $TempBar
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var max_temperature: int  = 10
@export var move_speed: float     = 60.0
@export var dir_change_time: float = 2.0

var temperature: int   = 0
var letter: String     = ""

var _move_dir: Vector2  = Vector2.ZERO
var _screen_rect: Rect2
var _entered_screen: bool = false   # true once penguin is inside viewport

func _ready() -> void:
	_screen_rect = get_viewport_rect()

	temp_bar.min_value = 0
	temp_bar.max_value = GameHandler.max_temperature
	temp_bar.value     = temperature
	_refresh_bar()
	animation_player.play("walking")
	letter_label.text = letter

	temp_timer.wait_time = 1.0
	temp_timer.autostart = true
	temp_timer.timeout.connect(_on_temp_tick)
	temp_timer.start()

	dir_timer.wait_time = dir_change_time
	dir_timer.autostart = false   # don't wander yet — walk inward first
	dir_timer.timeout.connect(_on_dir_change)

	# Walk toward the screen center on spawn
	_walk_toward_screen()

func _physics_process(_delta: float) -> void:
	velocity = _move_dir * move_speed
	move_and_slide()

	if animated_sprite_2d and _move_dir.x != 0:
		animated_sprite_2d.flip_h = _move_dir.x > 0

	# Once inside screen, switch to bounded wandering
	if not _entered_screen and _screen_rect.has_point(global_position):
		_entered_screen = true
		_pick_random_direction()
		dir_timer.start()

	# If somehow pushed outside, steer back in
	if _entered_screen and not _screen_rect.grow(-10).has_point(global_position):
		_walk_toward_screen()

func set_letter(l: String) -> void:
	letter = l
	if is_node_ready():
		letter_label.text = letter

func cool_down(amount: int = 1) -> void:
	temperature = clampi(temperature - amount, 0, max_temperature)
	_refresh_bar()

func apply_heat(amount: int) -> void:
	temperature = clampi(temperature + amount, 0, max_temperature)
	_refresh_bar()
	_check_death()

func _on_temp_tick() -> void:
	temperature = clampi(temperature + 1, 0, max_temperature)
	_refresh_bar()
	_check_death()

func _on_dir_change() -> void:
	_pick_random_direction()

func _walk_toward_screen() -> void:
	# Aim at a random point near the screen center area
	var target := Vector2(
		randf_range(_screen_rect.size.x * 0.2, _screen_rect.size.x * 0.8),
		randf_range(_screen_rect.size.y * 0.2, _screen_rect.size.y * 0.8)
	)
	_move_dir = (target - global_position).normalized()

func _pick_random_direction() -> void:
	# Random angle, but bias away from edges if close to border
	var margin := 60.0
	var pos := global_position
	var s := _screen_rect.size
	var angle := randf() * TAU

	# If near an edge, nudge direction toward center
	var to_center := (s / 2.0 - pos).normalized()
	var near_edge := (
		pos.x < margin or pos.x > s.x - margin or
		pos.y < margin or pos.y > s.y - margin
	)
	if near_edge:
		var random_dir := Vector2(cos(angle), sin(angle))
		_move_dir = (random_dir + to_center * 1.5).normalized()
	else:
		_move_dir = Vector2(cos(angle), sin(angle))
		
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if OS.get_keycode_string(event.keycode).to_upper() == letter:
			cool_down(1)

func _refresh_bar() -> void:
	temp_bar.value = temperature

	var fill := StyleBoxFlat.new()
	var danger_threshold := GameHandler.max_temperature - 3
	if temperature >= danger_threshold:
		fill.bg_color = Color(1.0, 0.15, 0.1)   # red   — danger
	elif temperature <= GameHandler.min_whistle_temp:
		fill.bg_color = Color(0.2, 0.5, 1.0)    # blue  — too cold
	else:
		fill.bg_color = Color(0.2, 0.85, 0.2)   # green — acceptable

	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.1, 0.1, 0.1)

	temp_bar.add_theme_stylebox_override("fill", fill)
	temp_bar.add_theme_stylebox_override("background", bg)

func _check_death() -> void:
	if temperature >= max_temperature:
		print("Penguin '%s' overheated!" % letter)
		queue_free()
