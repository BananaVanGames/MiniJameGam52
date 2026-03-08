extends Control

const MAIN_MENU = preload("uid://6n3h48sf0yhd")

@onready var title: Label = $VBoxContainer/Title
@onready var level: Label = $VBoxContainer/Level
@onready var points: Label = $VBoxContainer/Points
@onready var lost_penguins: Label = $VBoxContainer/LostPenguins
@onready var next: Button = $VBoxContainer/Next


func _ready() -> void:
	show_end_summary()


func show_end_summary() -> void:
	if GameHandler.score_points >= GameHandler.max_score_points:
		title.text = "LEVEL COMPLETED"
		next.visible = true
		GameHandler._win()
	else:
		title.text = "GAME OVER"
		next.visible = false
		GameHandler._lose()
	level.text = "You reached level " + str(GameHandler.level_number)
	points.text = "Points earned: " + str(GameHandler.score_points) + "/" + str(GameHandler.max_score_points)
	lost_penguins.text = "Lost Penguins: " + str(GameHandler.lost_penguins)


func _on_quit_pressed() -> void:
	get_tree().change_scene_to_packed(MAIN_MENU)


func _on_next_pressed() -> void:
	GameHandler.level_number += 1
	if GameHandler.level_number >= 3: 
		pass
	else:
		GameHandler.load_level(LevelData.LEVELS[GameHandler.level_number])
		GameHandler.reset_level_parameters()
		GameHandler.start_level.emit()
	queue_free()
