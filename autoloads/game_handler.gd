extends Node

signal score_changed(new_score: int, max_score: int)
signal whistle_blown()
signal level_won()
signal level_lost()
signal get_platform_positions(qtt_positions: int)

var level_number: int = 1
var max_score_points: int = 10 ## points needed to beat the level
var max_screen_penguins: int = 8 ## max penguins alive at once
var max_level_penguins: int = 20 ## max penguins per level
var max_temperature: int = 10 ## temperature at which a penguin dies
var freezing_temp: int = 2 ## acceptable temp range low  (inclusive)
var auto_whistle_interval: float = 15.0 ## seconds between automatic whistles
var lost_penguins: int = 0 ## Number of penguins that were lost per level

var score_points: int = 0
var level_active: bool = false

var random_platform_positions: Array = []


func _process(_delta: float) -> void:
	if not level_active:
		return


func set_random_platform_positions(values: Array) -> void:
	random_platform_positions = values
	print("PLATFORM VALUES: ", random_platform_positions)


func add_lost_penguin() -> void:
	lost_penguins += 1


func get_max_level_penguins() -> int:
	return max_level_penguins


func start_level() -> void:
	lost_penguins = 0
	score_points = 0
	level_active = true
	score_changed.emit(score_points, max_score_points)


func stop_level() -> void:
	level_active = false


## Load a level config dict — call before start_level()
## e.g. GameHandler.load_level(LevelData.LEVELS[1])
func load_level(config: Dictionary) -> void:
	level_number = config.get("level_number", 1)
	max_score_points = config.get("max_score_points", 10)
	max_screen_penguins = config.get("max_screen_penguins", 8)
	max_level_penguins = config.get("max_level_penguins", 20)
	max_temperature = config.get("max_temperature", 100)
	freezing_temp = config.get("freezing_temp", 2)
	auto_whistle_interval = config.get("auto_whistle_interval", 15.0)


func player_blows_whistle() -> void:
	whistle_blown.emit()

	if not level_active:
		return

	send_penguins_to_platform()


func send_penguins_to_platform() -> void:
	var scored := 0
	var called_penguins: Array = get_tree().get_nodes_in_group("penguins")
	var qtt_penguins: int = called_penguins.size()
	get_platform_positions.emit(qtt_penguins)

	for penguin in called_penguins:
		var temp: int = penguin.temperature
		if temp >= freezing_temp:
			penguin.move_to()
			scored += 1

	if scored > 0:
		_add_score(scored)


func trigger_loss() -> void:
	if not level_active:
		return
	_lose()


func _add_score(amount: int) -> void:
	score_points = mini(score_points + amount, max_score_points)
	score_changed.emit(score_points, max_score_points)
	if score_points >= max_score_points:
		_win()


func _win() -> void:
	level_active = false
	level_won.emit()


func _lose() -> void:
	level_active = false
	level_lost.emit()
