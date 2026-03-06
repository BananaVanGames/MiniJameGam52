extends CharacterBody2D

@export var max_temperature: int   = 10
@export var move_speed: float      = 60.0   ## pixels per second
@export var dir_change_time: float = 1.5    ## seconds between direction changes

var temperature: int  = 0
var letter: String    = ""          ## set externally by spawner before _ready
var _move_dir: Vector2 = Vector2.ZERO

func _ready() -> void:
	# --- Temperature bar setup ---
	$TempBar.min_value = 0
	$TempBar.max_value = max_temperature
	$TempBar.value     = temperature
	_update_bar_color()

	# --- Letter label ---
	$LetterLabel.text = letter   # letter must be assigned before _ready via set_letter()
		# --- Timers ---
	$DirTimer.wait_time = dir_change_time
	$DirTimer.autostart = true
	$DirTimer.timeout.connect(_on_dir_change)

	# Pick an initial direction immediately
	_pick_random_direction()

func _physics_process(_delta: float) -> void:
	velocity = _move_dir * move_speed
	move_and_slide()

	# Flip sprite to face movement direction (optional, remove if not needed)
	if _move_dir.x != 0:
		$Sprite2D.flip_h = _move_dir.x < 0
		
func set_letter(l: String) -> void:
	letter = l
	if is_node_ready():
		$LetterLabel.text = letter

func cool_down(amount: int = 1) -> void:
	temperature = clampi(temperature - amount, 0, max_temperature)
	_sync_bar()
	
func apply_heat(amount: int) -> void:
	temperature = clampi(temperature + amount, 0, max_temperature)
	_sync_bar()
	_check_death()
	
func _on_temp_tick() -> void:
	temperature = clampi(temperature + 1, 0, max_temperature)
	_sync_bar()
	_check_death()
	
func _on_dir_change() -> void:
	_pick_random_direction()

func _pick_random_direction() -> void:
	# Random angle → unit vector so movement is truly omnidirectional
	var angle: float = randf() * TAU          # TAU = 2π
	_move_dir = Vector2(cos(angle), sin(angle))

func _sync_bar() -> void:
	$TempBar.value = temperature
	_update_bar_color()

func _update_bar_color() -> void:
	var t: float = float(temperature) / float(max_temperature)  # 0.0 → 1.0
	# Interpolate green (cool) → yellow → red (hot)
	var color: Color = Color(t, 1.0 - t, 0.0)
	# ProgressBar fill color via theme override
	$TempBar.add_theme_color_override("font_color", color)       # fallback
	var style := StyleBoxFlat.new()
	style.bg_color = color
	$TempBar.add_theme_stylebox_override("fill", style)

func _check_death() -> void:
	if temperature >= max_temperature:
		_die()

func _die() -> void:
	# TODO: play death animation / emit signal before freeing
	print("Penguin '%s' overheated!" % letter)
	queue_free()
