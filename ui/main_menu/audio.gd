extends VBoxContainer

const MIN_DB = -60.0
const MAX_DB = 0.0

@export var master_slider: HSlider
@export var music_slider: HSlider
@export var sfx_slider: HSlider

var entered_audio: bool = false
var master: float = 0
var music: float = 0
var sfx: float = 0


func _ready():
	_sync_sliders()

	master_slider.value_changed.connect(_on_master_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)


func get_audio_settings() -> Dictionary:
	if entered_audio:
		return { "master_volume": master, "music_volume": music, "sfx_volume": sfx }
	else:
		return {}

func _sync_sliders():
	master = _db_to_slider(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	master_slider.value = master
	music = _db_to_slider(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	music_slider.value = music
	sfx = _db_to_slider(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))
	sfx_slider.value = sfx


func _slider_to_db(value: float) -> float:
	if value <= 0.0:
		return MIN_DB

	var linear = value / 100.0
	var db = linear_to_db(linear)
	return clamp(db, MIN_DB, MAX_DB)


func _db_to_slider(db: float) -> float:
	if db <= MIN_DB:
		return 0.0
	var linear = db_to_linear(db)
	return clamp(linear * 100.0, 0.0, 100.0)


func _set_volume(bus_name: String, value: float):
	var db = _slider_to_db(value)
	var bus_index = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_index, db)
	AudioServer.set_bus_mute(bus_index, db <= MIN_DB)
	match bus_index:
		0: master = value
		1: music = value
		2: sfx = value


func _on_master_volume_changed(value: float):
	_set_volume("Master", value)


func _on_music_volume_changed(value: float):
	_set_volume("Music", value)


func _on_sfx_volume_changed(value: float):
	_set_volume("SFX", value)
