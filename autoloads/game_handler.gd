extends Node

signal score_changed(new_score: int, max_score: int)
signal whistle_blown()
signal level_won()
signal level_lost()

var level_number: int = 1
var max_score_points: int = 10 ## points needed to beat the level
var max_screen_penguins: int = 8 ## max penguins alive at once
var max_level_penguins: int = 20 ## max penguins per level
var max_temperature: int = 10 ## temperature at which a penguin dies
var min_whistle_temp: int = 2 ## acceptable temp range low  (inclusive)
var max_whistle_temp: int = 5 ## acceptable temp range high (inclusive)
var auto_whistle_interval: float = 15.0 ## seconds between automatic whistles
var lost_penguins: int = 0 ## Number of penguins that were lost per level

var score_points: int = 0
var level_active: bool = false


func _process(_delta: float) -> void:
	if not level_active:
		return


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
	min_whistle_temp = config.get("min_whistle_temp", 2)
	max_whistle_temp = config.get("max_whistle_temp", 5)
	auto_whistle_interval = config.get("auto_whistle_interval", 15.0)


func player_blows_whistle() -> void:
	whistle_blown.emit()

	if not level_active:
		return

	freeze_penguins()


func freeze_penguins() -> void:
	var scored := 0
	for penguin in get_tree().get_nodes_in_group("penguins"):
		var temp: int = penguin.temperature
		if temp >= min_whistle_temp and temp <= max_whistle_temp:
			#penguin.send_to_safe_zone()   # defined in Penguin.gd
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
