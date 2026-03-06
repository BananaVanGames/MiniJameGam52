extends Node

#signal progress_changed(progress)
signal load_finished

var loading_screen: PackedScene = preload("uid://bexgy884vcrx3")
var loaded_resource: PackedScene
var scene_path: String
# the reason the progress variable is a one-element array is that, 
# in gdscript, arrays are passed by reference in function args, 
#so the get_status function updates that very same variable, not a copy of it. 
#in a language like c++ you would be able to pass a reference or pointer to the float or double
var progress: Array = []
var use_sub_threads: bool = false


func _ready() -> void:
	set_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Avoid warning
	var warning_delta = delta
	if warning_delta: pass

	var load_status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	#progress_changed.emit(progress[0])
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
		ResourceLoader.THREAD_LOAD_LOADED:
			loaded_resource = ResourceLoader.load_threaded_get(scene_path)
			get_tree().change_scene_to_packed(loaded_resource)
			load_finished.emit()


func load_scene(_scene_path: String) -> void:
	scene_path = _scene_path

	var new_load_screen = loading_screen.instantiate()
	add_child(new_load_screen)
	#progress_changed.connect(new_load_screen._on_progress_changed)
	load_finished.connect(new_load_screen._on_load_finished)

	await new_load_screen.loading_screen_ready

	start_load()


func start_load() -> void:
	var state = ResourceLoader.load_threaded_request(scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true)
