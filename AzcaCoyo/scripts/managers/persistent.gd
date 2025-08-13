extends Node3D

var last_scene: Node3D

func _ready() -> void:
	GlobalSceneManager.bind_on_scene_loaded(on_scene_loaded, true)
	GlobalSceneManager.load_perfil()
	
func _exit_tree() -> void:	
	GlobalSceneManager.bind_on_scene_loaded(on_scene_loaded, false)

func on_scene_loaded(new_scene:PackedScene):
	if last_scene != null:
		last_scene.free()
		last_scene = null
	
	last_scene = new_scene.instantiate()
	add_child(last_scene)
#	//GlobalSignals.on_persistent_scene_loaded.emit(last_scene)
