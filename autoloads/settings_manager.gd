extends Node

const CONFIG_PATH := "user://settings.cfg"

var default_video_settings := {
	"resolution": Vector2i(1280, 720),
	"fullscreen": false,
	"borderless": false,
	"vsync": true,
}

var default_audio_settings := {
	"master_volume": 0.5,
	"music_volume": 0.5,
	"sfx_volume": 0.3,
}

var video_settings: Dictionary
var audio_settings: Dictionary


func _ready():
	load_settings()


func save_settings(new_video: Dictionary, new_audio: Dictionary):
	var config := ConfigFile.new()

	print("VALUES OF VIDEO: ", new_video)
	if new_video.is_empty():
		new_video = video_settings

	config.set_value("video", "resolution", new_video["resolution"])
	config.set_value("video", "fullscreen", new_video["fullscreen"])
	config.set_value("video", "borderless", new_video["borderless"])
	config.set_value("video", "vsync", new_video["vsync"])

	if new_audio.is_empty():
		new_audio = audio_settings

	config.set_value("audio", "master_volume", new_audio["master_volume"])
	config.set_value("audio", "music_volume", new_audio["master_volume"])
	config.set_value("audio", "sfx_volume", new_audio["master_volume"])

	config.save(CONFIG_PATH)


func load_settings():
	var config := ConfigFile.new()
	var err := config.load(CONFIG_PATH)
	if err != OK:
		return

	for section in ["video", "audio"]:
		if not config.has_section(section):
			continue

		var settings := {}

		for key in config.get_section_keys(section):
			settings[key] = config.get_value(section, key)

		if section == "video":
			apply_video_settings(settings)
		elif section == "audio":
			apply_audio_settings(settings)


func apply_video_settings(video_values: Dictionary):
	var v = video_values
	video_settings = video_values

	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if v["vsync"] else DisplayServer.VSYNC_DISABLED
	)
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if v["fullscreen"] else DisplayServer.WINDOW_MODE_WINDOWED
	)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, v["borderless"])
	DisplayServer.window_set_size(v["resolution"])


func apply_audio_settings(audio_values: Dictionary):
	audio_settings = audio_values

	var master_db = linear_to_db(clamp(audio_values["master_volume"], 0.0, 1.0))
	var music_db = linear_to_db(clamp(audio_values["music_volume"], 0.0, 1.0))
	var sfx_db = linear_to_db(clamp(audio_values["sfx_volume"], 0.0, 1.0))

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master_db)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), music_db)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), sfx_db)
