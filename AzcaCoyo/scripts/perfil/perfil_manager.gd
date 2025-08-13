extends Node3D

@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var directional_light_3d: DirectionalLight3D = $DirectionalLight3D
@onready var camera_3d_perfil: Camera3D = $Camera3D_Perfil
@onready var mesh_mapa: Node3D = $MeshMapa
@onready var sitios: Node3D = $sitios

var _environment: Environment;
var diccionario_interceptores: Dictionary;

func _ready() -> void:
	get_viewport().disable_3d = false
	_environment = world_environment.environment;
	
	#var mapacdmx_Interceptores = mesh_mapa.get_node("mapacdmx_Interceptores")
	#if mapacdmx_Interceptores:
		#for _mesh in mapacdmx_Interceptores.get_children():
			#var _mesh_name = _mesh.name;
			#var interceptor_name = _mesh_name.split('_')[1]
			#diccionario_interceptores[interceptor_name] = _mesh
			#_mesh.material_override["shader_parameter/speed"] = 0.2
			#_mesh.material_override["shader_parameter/alpha_value"] = 0.0
	#else:
		#print("mapacdmx_Interceptores no encontrado")
	print("mapacdmx_Interceptores no encontrado")
	
	GlobalSignals.connect_on_ui_change(_on_ui_change, true)
	GlobalSignals.connect_on_click_interceptor(_on_click_interceptor, true)
	
func _exit_tree() -> void:
	GlobalSignals.connect_on_ui_change(_on_ui_change, false)
	GlobalSignals.connect_on_click_interceptor(_on_click_interceptor, false)
	
func _on_ui_change(tipo_modulo: TIPO_MODULO.UI): 
	
	if tipo_modulo != TIPO_MODULO.UI.PARTICULAR:
		if tipo_modulo == TIPO_MODULO.UI.MAPA:
			# TODO: CAMBAIR ENVIRONMENTS PARA UN GLOBAL HANDER
			#world_environment.environment = _environment;
			#get_viewport().disable_3d = false
			directional_light_3d.visible = true
			directional_light_3d.set_process_mode(Node.PROCESS_MODE_INHERIT)
			camera_3d_perfil.visible = true
			camera_3d_perfil.set_process_input(true)
			#comentado
			#mesh_mapa.set_process(true)
			#for _mini in sitios.get_children():
				#_mini.set_process(true)
				#_mini.visible = true
		else:
			# TODO: CAMBAIR ENVIRONMENTS PARA UN GLOBAL HANDER
			#world_environment.environment = null;
			#get_viewport().disable_3d = true
			directional_light_3d.visible = false
			directional_light_3d.set_process_mode(Node.PROCESS_MODE_DISABLED)
			camera_3d_perfil.visible = false
			camera_3d_perfil.set_process_input(false)
			#mesh_mapa.set_process(false)
			#for _mini in sitios.get_children():
				#_mini.set_process(false)
				#_mini.visible = false	
		
func _on_click_interceptor(_interceptor_abreviacion: String):
	# por si se necesita que solo ilumine el interceptor seleccionado actual
	#if _interceptor_abreviacion == "NA":
		#return;
	
	for key in diccionario_interceptores.keys():
		var _mesh = diccionario_interceptores.get(key);
		_mesh.material_override["shader_parameter/speed"] = 0.2
		_mesh.material_override["shader_parameter/alpha_value"] = 0.0
	
	var mesh_instance = diccionario_interceptores.get(_interceptor_abreviacion);
	if mesh_instance:
		mesh_instance.material_override["shader_parameter/speed"] = 1.0
		mesh_instance.material_override["shader_parameter/alpha_value"] = 1.0
