extends Node2D

const WHISTLE_1 = preload("uid://dwu1j4aacffsm")
const WHISTLE_2 = preload("uid://ddafy6ighwblf")
const WHISTLE_3 = preload("uid://obcflc0rqhme")
const WHISTLE_SOUNDS = [WHISTLE_1, WHISTLE_2, WHISTLE_3]

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func blow_whistle() -> void:
	audio_stream_player.stream = WHISTLE_SOUNDS.pick_random()
	audio_stream_player.play()

	animation_player.stop()
	animation_player.play("blow")
