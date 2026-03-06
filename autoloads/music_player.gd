extends AudioStreamPlayer

var target_dB: float = 0
var fade_volume: bool = false

func _process(_delta: float) -> void:
	if fade_volume:
		var tween = create_tween()
		tween.tween_property(self,"volume_db", linear_to_db(target_dB), 0.1)
		fade_volume = false
		

func _ready() -> void:
	bus = "Master"


func load_track(audio: AudioStream) -> void:
	stream = audio


func change_db_to(new_dB: float) -> void:
	fade_volume = true
	target_dB = new_dB
