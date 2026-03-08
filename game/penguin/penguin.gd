extends CharacterBody2D

const COLOR_DANGER = Color("ff0000")
const COLOR_COLD = Color("00aeff")
const COLOR_MEDIUM = Color("ffd264")

const GOING_PLATFORM_SPEED = 3
const FAHHH_SOUND = preload("uid://cl74wf4i1bb5o")
const DEATH_SOUND = preload("uid://c2lnaek6benuk")

@export var min_temp: int = -3
@export var max_temp: int = 10
@export var move_speed: float = 60.0
@export var dir_change_time: float = 2.0
@export var idle_chance: float = 0.35 ## 0.0–1.0 probability of stopping on dir change
@export var idle_duration: float = 2.7 ## seconds to stay idle before 

var temperature: int = 3
var letter: String = ""

var tex_tecla = load("res://game/penguin/art/tecla.png")
var tex_tecla_press = load("res://game/penguin/art/tecla-presionada.png")
var termometro_medium = load("res://game/penguin/art/termometer_medium.png")
var termometro_cold = load("res://game/penguin/art/termometer_cold.png")

var _move_dir: Vector2 = Vector2.ZERO
var _screen_rect: Rect2
var _entered_screen: bool = false # true once penguin is inside viewport
var _is_going_to_platform: bool = false
var _platform_target: Vector2 = Vector2.ZERO
var _arrival_threshold: float = 8.0 # distance in px to consider "arrived"
var _was_frozen: bool = false
var _is_on_platform: bool = false
var _is_idle: bool = false
var _is_dead: bool = false

@onready var dir_timer: Timer = $DirTimer
@onready var temp_timer: Timer = $TempTimer
@onready var letter_label: Label = $LetterLabel
@onready var temp_bar: ProgressBar = $TempBar
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var tecla: Sprite2D = $Tecla
@onready var termometer: Sprite2D = $Termometer
@onready var termometer_red: AnimatedSprite2D = $TermometerRed
@onready var icecube: Sprite2D = $Icecube
@onready var death_sound: AudioStreamPlayer = $DeathSound
@onready var key_sound: AudioStreamPlayer = $KeySound


func _ready() -> void:
	_screen_rect = get_viewport_rect()
	temperature = (GameHandler.freezing_temp + GameHandler.max_temperature) / 2
	temp_bar.min_value = 0
	temp_bar.max_value = GameHandler.max_temperature
	temp_bar.value = temperature
	_refresh_bar()
	animated_sprite_2d.play("walking")
	letter_label.text = letter
	icecube.visible = false

	temp_timer.wait_time = 1.0
	temp_timer.autostart = true
	temp_timer.timeout.connect(_on_temp_tick)
	temp_timer.start()

	dir_timer.wait_time = dir_change_time
	dir_timer.autostart = false
	dir_timer.timeout.connect(_on_dir_change)

	# Walk toward the screen center on spawn
	call_deferred("_walk_toward_screen")


func _physics_process(_delta: float) -> void:
	if _is_dead or _is_on_platform:
		velocity = Vector2.ZERO
		return

	if _is_going_to_platform and not _is_dead:
		if animated_sprite_2d.animation != "run":
			animated_sprite_2d.play("run")
		_move_dir = (_platform_target - global_position).normalized()
		velocity = _move_dir * move_speed * GOING_PLATFORM_SPEED
		move_and_slide()
		if _move_dir.x != 0:
			animated_sprite_2d.flip_h = _move_dir.x > 0
		if global_position.distance_to(_platform_target) <= _arrival_threshold:
			_on_arrived_at_platform()
		return

	if _is_idle:
		velocity = Vector2.ZERO
		move_and_slide()
		return

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
	if _entered_screen and not _screen_rect.grow(-60).has_point(global_position):
		_walk_toward_screen()


func _input(event: InputEvent) -> void:
	if _is_dead:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if OS.get_keycode_string(event.keycode).to_upper() == letter:
			tecla.texture = tex_tecla_press
			key_sound.play()
			await get_tree().create_timer(0.12).timeout
			tecla.texture = tex_tecla
			cool_down(1)


func set_letter(l: String) -> void:
	letter = l
	if is_node_ready():
		letter_label.text = letter


func cool_down(amount: int = 1) -> void:
	if _is_dead:
		return
	temperature = clampi(temperature - amount, min_temp, max_temp)
	_refresh_bar()


func apply_heat(amount: int) -> void:
	if _is_dead:
		return
	temperature = clampi(temperature + amount, min_temp, max_temp)
	_refresh_bar()
	_check_death()


func move_to() -> void:
	if _is_dead or _is_on_platform:
		return
	if GameHandler.random_platform_positions.is_empty():
		return

	_platform_target = GameHandler.random_platform_positions.pop_front()
	_is_going_to_platform = true
	_was_frozen = temperature <= GameHandler.freezing_temp
	temp_timer.stop()
	dir_timer.stop()
	_move_dir = (_platform_target - global_position).normalized()


func penguin_death() -> void:
	GameHandler.add_lost_penguin()
	animated_sprite_2d.play("dead")
	if randf_range(0, 1) < 0.25:
		death_sound.stream = FAHHH_SOUND
	else:
		death_sound.stream = DEATH_SOUND
	death_sound.play()


func _on_temp_tick() -> void:
	if _is_dead:
		return
	temperature = clampi(temperature + 1, min_temp, max_temp)
	_refresh_bar()
	_check_death()


func _on_dir_change() -> void:
	if _is_idle or _is_dead:
		return
	_pick_random_direction()


func _walk_toward_screen() -> void:
	var s := _screen_rect.size
	# Always aim at screen center — no randomness when recovering from edge
	var target := s / 2.0
	var dir := target - global_position
	if dir.length() < 1.0:
		dir = Vector2(cos(randf() * TAU), sin(randf() * TAU))
	_move_dir = dir.normalized()
	# Cancel idle so the penguin actually moves
	_is_idle = false
	_play_walk()


func _pick_random_direction() -> void:
	if randf() < idle_chance:
		_start_idle()
		return

	var margin := 60.0
	var pos := global_position
	var s := _screen_rect.size
	var angle := randf() * TAU
	var random_dir := Vector2(cos(angle), sin(angle)) # always valid unit vector

	var near_edge := (
		pos.x < margin or pos.x > s.x - margin
		or pos.y < margin or pos.y > s.y - margin
	)
	if near_edge:
		var to_center := s / 2.0 - pos
		if to_center.length() > 1.0:
			_move_dir = (random_dir + to_center.normalized() * 1.5).normalized()
		else:
			_move_dir = random_dir
	else:
		_move_dir = random_dir

	# Final safety — should never be zero now but just in case
	if _move_dir.length() < 0.1:
		_move_dir = Vector2(1, 0).rotated(randf() * TAU)

	_play_walk()


func _start_idle() -> void:
	_is_idle = true
	_move_dir = Vector2.ZERO
	animated_sprite_2d.play("idle")
	# Resume walking after idle_duration seconds
	await get_tree().create_timer(idle_duration).timeout
	if not _is_on_platform and not _is_going_to_platform and not _is_dead:
		_is_idle = false
		_pick_random_direction()


func _play_walk() -> void:
	if not _is_on_platform and not _is_dead:
		animated_sprite_2d.play("walking")


func _on_arrived_at_platform() -> void:
	_is_going_to_platform = false
	_is_on_platform = true # ← locks physics permanently
	velocity = Vector2.ZERO
	GameHandler.notify_penguin_arrived(_was_frozen)
	move_and_slide() # one last slide to flush velocity

	if _was_frozen:
		icecube.visible = true
		animated_sprite_2d.animation = "idle"
		var num_frames = animated_sprite_2d.sprite_frames.get_frame_count("idle")
		animated_sprite_2d.frame = randi_range(0, num_frames)
		animated_sprite_2d.pause()
		await get_tree().create_timer(1.0).timeout
		queue_free()
	else:
		penguin_death()
		await animated_sprite_2d.animation_finished
		queue_free()


func _set_danger_state(fill: StyleBoxFlat) -> void:
	fill.bg_color = COLOR_DANGER

	termometer.visible = false
	termometer_red.visible = true

	if not termometer_red.is_playing():
		termometer_red.play()


func _set_medium_state(fill: StyleBoxFlat) -> void:
	fill.bg_color = COLOR_MEDIUM

	termometer.visible = true
	termometer_red.visible = false
	termometer.texture = termometro_medium


func _set_cold_state(fill: StyleBoxFlat) -> void:
	fill.bg_color = COLOR_COLD

	termometer.visible = true
	termometer_red.visible = false
	termometer.texture = termometro_cold


func _refresh_bar() -> void:
	temp_bar.value = temperature

	var danger_threshold: int = int(GameHandler.max_temperature * 0.7)
	var fill := temp_bar.get_theme_stylebox("fill").duplicate() as StyleBoxFlat

	if temperature >= danger_threshold:
		_set_danger_state(fill)
	elif temperature <= GameHandler.freezing_temp:
		_set_cold_state(fill)
	else:
		_set_medium_state(fill)

	temp_bar.add_theme_stylebox_override("fill", fill)


func _check_death() -> void:
	if _is_dead:
		return
	if temperature >= max_temp:
		_is_dead = true
		_is_idle = false
		_is_going_to_platform = false
		animated_sprite_2d.stop()
		dir_timer.stop()
		temp_timer.stop()

		penguin_death()

		await animated_sprite_2d.animation_finished
		queue_free()
