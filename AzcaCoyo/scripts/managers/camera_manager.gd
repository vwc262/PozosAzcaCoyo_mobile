extends Node3D

#region Variables de Edicion
@export var transition_time : float = 1.2
#endregion

#region Relacion de POIS por TipoVista
@export var posicion_inicial : Transform3D
@export var camaras_azcapotzalco : Dictionary  = {}
@export var camaras_coyoacan : Dictionary  = {}
#endregion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	suscribe_signals()
	
func suscribe_signals():
	GlobalSignals.connect_on_mini_site_clicked(_on_mini_site_clicked, true)
	GlobalSignals.connect_on_agregar_poi_perfil(on_agregar_poi_perfil, true)
	GlobalSignals.connect_on_unload_perfil(_on_unload_perfil, true)

func _exit_tree() -> void:
	GlobalSignals.connect_on_mini_site_clicked(_on_mini_site_clicked, false)
	GlobalSignals.connect_on_agregar_poi_perfil(on_agregar_poi_perfil, false)
	GlobalSignals.connect_on_unload_perfil(_on_unload_perfil, false)
	
func _on_mini_site_clicked(_id: int, _id_proyecto: int):
	var _transform : Transform3D = get_perfil_camera(_id, _id_proyecto)

	if _transform != null:
		go_to_mini_site(_transform)
	
func on_agregar_poi_perfil(_id_estacion: int, _id_proyecto: int, _transform: Transform3D):
	if _id_proyecto == 0:
		posicion_inicial = _transform
	elif _id_proyecto == 22:
		if !camaras_azcapotzalco.has(_id_estacion):
			camaras_azcapotzalco[_id_estacion] = {}

		camaras_azcapotzalco[_id_estacion] = _transform
	else:
		if !camaras_coyoacan.has(_id_estacion):
			camaras_coyoacan[_id_estacion] = {}

		camaras_coyoacan[_id_estacion] = _transform 
	
func _on_unload_perfil():
	camaras_azcapotzalco = {}

func get_perfil_camera(_id_estacion: int, _id_proyecto: int) -> Transform3D:
	if _id_proyecto == 0:
		return posicion_inicial
	elif _id_proyecto == 22:
		return camaras_azcapotzalco[_id_estacion]
	else:
		return camaras_coyoacan[_id_estacion]

func go_to_mini_site(_transform: Transform3D):
	if !GlobalSignals.isTransitioning:
		GlobalSignals.isTransitioning = true;
		
		_transform.origin.y = clamp(_transform.origin.y, GlobalData.min_zoom, GlobalData.max_zoom)
		
		var current_camera = get_viewport().get_camera_3d()
		await get_tween().tween_property(current_camera,"global_transform",_transform,  transition_time).finished
		GlobalSignals.isTransitioning = false
		
func get_tween()->Tween:
	var tween = create_tween().set_parallel(true) 
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	return tween;
