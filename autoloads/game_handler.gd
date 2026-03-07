extends Node

var level_number: int            = 1
var max_score_points: int        = 10   ## points needed to beat the level
var max_penguins: int            = 8    ## max penguins alive at once
var max_temperature: int         = 10   ## temperature at which a penguin dies
var min_whistle_temp: int        = 2    ## acceptable temp range low  (inclusive)
var max_whistle_temp: int        = 5    ## acceptable temp range high (inclusive)
var auto_whistle_interval: float = 15.0 ## seconds between automatic whistles

var score_points: int  = 0
var level_active: bool = false

signal score_changed(new_score: int, max_score: int)
signal whistle_blown()
signal level_won()
signal level_lost()
signal auto_whistle_tick(time_remaining: float)  ## for UI countdown display

var _whistle_timer: Timer
var _whistle_elapsed: float = 0.0

func _ready() -> void:
	_setup_whistle_timer()

func _process(delta: float) -> void:
	if not level_active:
		return
	_whistle_elapsed += delta
	var remaining := auto_whistle_interval - _whistle_elapsed
	auto_whistle_tick.emit(maxf(remaining, 0.0))

func start_level() -> void:
	score_points   = 0
	level_active   = true
	_whistle_elapsed = 0.0
	_whistle_timer.wait_time = auto_whistle_interval
	_whistle_timer.start()
	score_changed.emit(score_points, max_score_points)

func stop_level() -> void:
	level_active = false
	_whistle_timer.stop()

## Load a level config dict — call before start_level()
## e.g. GameHandler.load_level(LevelData.LEVELS[1])
func load_level(config: Dictionary) -> void:
	level_number           = config.get("level_number",           1)
	max_score_points       = config.get("max_score_points",       10)
	max_penguins           = config.get("max_penguins",           8)
	max_temperature        = config.get("max_temperature",        100)
	min_whistle_temp       = config.get("min_whistle_temp",       2)
	max_whistle_temp       = config.get("max_whistle_temp",       5)
	auto_whistle_interval  = config.get("auto_whistle_interval",  15.0)

func blow_whistle() -> void:
	if not level_active:
		return

	whistle_blown.emit()
	_whistle_elapsed = 0.0
	_whistle_timer.start()

	var scored := 0
	for penguin in get_tree().get_nodes_in_group("penguins"):
		var temp: int = penguin.temperature
		if temp >= min_whistle_temp and temp <= max_whistle_temp:
			#penguin.send_to_safe_zone()   # defined in Penguin.gd
			scored += 1

	if scored > 0:
		_add_score(scored)

func _setup_whistle_timer() -> void:
	_whistle_timer = Timer.new()
	_whistle_timer.one_shot  = false
	_whistle_timer.autostart = false
	_whistle_timer.timeout.connect(_on_auto_whistle)
	add_child(_whistle_timer)

func _on_auto_whistle() -> void:
	blow_whistle()

func _add_score(amount: int) -> void:
	score_points = mini(score_points + amount, max_score_points)
	score_changed.emit(score_points, max_score_points)
	if score_points >= max_score_points:
		_win()

func trigger_loss() -> void:
	if not level_active:
		return
	_lose()

func _win() -> void:
	level_active = false
	_whistle_timer.stop()
	level_won.emit()

func _lose() -> void:
	level_active = false
	_whistle_timer.stop()
	level_lost.emit()
