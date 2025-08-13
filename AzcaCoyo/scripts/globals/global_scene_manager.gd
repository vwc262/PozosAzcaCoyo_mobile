extends Node3D

#region Signals
signal on_new_scene
signal on_scene_loaded 
signal on_load_progress
#endregion

#region Variables
var progress = []
var scene_load_status = 0
var scene_name = ''
var currentParticular = null
var last_scene_loaded : Resource
var last_sitename : String = ''
#endregion

#region Rutas Escenas
var scene_perfil = "res://scenes/world/"
var scene_particular = "res://scenes/sitios/"
#endregion

#region Modulo Actual
var current_module : TIPO_MODULO.MODULES  = TIPO_MODULO.MODULES.PERFIL
var aux_module : TIPO_MODULO.MODULES = TIPO_MODULO.MODULES.PERFIL
#endregion

func bind_on_new_scene(callback:Callable, do_bind:bool)->void:
	if do_bind:
		on_new_scene.connect(callback)
	else:
		on_new_scene.disconnect(callback)	

func bind_on_scene_loaded(callback:Callable, do_bind:bool)->void:
	if do_bind:
		on_scene_loaded.connect(callback)
	else:
		on_scene_loaded.disconnect(callback)

func load_perfil():
	scene_name = scene_perfil + "perfil.tscn"
	aux_module =  TIPO_MODULO.MODULES.PERFIL
	load_scene()

func load_particular(particular_name : String):
	scene_name = scene_particular + particular_name + ".tscn"
	aux_module = TIPO_MODULO.MODULES.PARTICULAR
	load_scene()

func load_scene():
	if scene_name != last_sitename:
		last_sitename = scene_name
		scene_load_status = 0
		set_process(true)
		#on_new_scene.emit()
		

func _process(_delta: float) -> void:
	if last_scene_loaded != null: 
		last_scene_loaded = null
	
	ResourceLoader.load_threaded_request(scene_name)
	
	scene_load_status = ResourceLoader.load_threaded_get_status(scene_name, progress)
	on_load_progress.emit(progress[0])
	
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		var new_scene = ResourceLoader.load_threaded_get(scene_name)
		last_scene_loaded = new_scene
		current_module = aux_module
		on_scene_loaded.emit(new_scene)
		set_process(false)

# TODO: no se ocupa?
func suscribe_callback(callback_on_scene,callback_on_scene_loaded,callback_on_progress):
	if callback_on_scene != null : on_new_scene.connect(callback_on_scene)		
	if callback_on_scene_loaded != null : on_scene_loaded.connect(callback_on_scene_loaded)
	if callback_on_progress != null : on_load_progress.connect(callback_on_progress)
