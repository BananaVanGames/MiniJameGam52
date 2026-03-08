extends Control

const WHISTLE_1 = preload("uid://dwu1j4aacffsm")
const WHISTLE_2 = preload("uid://ddafy6ighwblf")
const WHISTLE_3 = preload("uid://obcflc0rqhme")
const WHISTLE_SOUNDS = [WHISTLE_1, WHISTLE_2, WHISTLE_3]
const PUP = preload("uid://xvk4jkqkwkth")

@onready var points: Label = $VBoxContainer/Points
@onready var lost_penguins: Label = $VBoxContainer/LostPenguins
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	points.text = "Your won with: " + str(GameHandler.total_score_points) + " points."
	if GameHandler.total_lost_penguins > 0:
		lost_penguins.text = "Your lost: " + str(GameHandler.total_lost_penguins) + " poor penguins."
	else:
		lost_penguins.text = "No penguins were harmed during this game. You're awesome!"


func _on_quit_pressed() -> void:
	audio_stream_player.stream = PUP
	audio_stream_player.play()
	await get_tree().create_timer(0.2).timeout
	SceneLoader.load_scene("uid://6n3h48sf0yhd")


func _on_try_again_pressed() -> void:
	audio_stream_player.stream = WHISTLE_SOUNDS.pick_random()
	audio_stream_player.play()
	await get_tree().create_timer(0.2).timeout
	SceneLoader.load_scene("uid://bdbxg1pft4grf")
