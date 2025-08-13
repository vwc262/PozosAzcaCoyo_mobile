extends Node3D

#region Variables de Edicion
@export var transition_time : float = 1.2
#endregion

#region Relacion de POIS por TipoVista
@export var camaras_perfil : Dictionary  = {}
@export var camaras_particular : Dictionary  = {}
#endregion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	suscribe_signals()
	
func suscribe_signals():
	GlobalSignals.connect_on_mini_site_clicked(_on_mini_site_clicked, true)
	GlobalSignals.connect_on_go_to_poi(_on_poi_clicked, true)
	GlobalSignals.connect_on_agregar_poi_perfil(on_agregar_poi_perfil, true)
	GlobalSignals.connect_on_agregar_poi_particular(on_agregar_poi_particular, true)
	GlobalSignals.connect_on_unload_perfil(_on_unload_perfil, true)
	GlobalSignals.connect_on_unload_particular(_on_unload_particular, true)

func _exit_tree() -> void:
	GlobalSignals.connect_on_mini_site_clicked(_on_mini_site_clicked, false)
	GlobalSignals.connect_on_go_to_poi(_on_poi_clicked, false)
	GlobalSignals.connect_on_agregar_poi_perfil(on_agregar_poi_perfil, false)
	GlobalSignals.connect_on_agregar_poi_particular(on_agregar_poi_particular, false)
	GlobalSignals.connect_on_unload_perfil(_on_unload_perfil, false)
	GlobalSignals.connect_on_unload_particular(_on_unload_particular, false)
	
func _on_poi_clicked(tipo: TIPO_POI.ENUM_POI):
	var _transform : Transform3D = get_poi_camera(tipo)

	if _transform != null:
		go_to_poi_particular(_transform)
	
func _on_mini_site_clicked(_id_estacion: int):
	var _transform : Transform3D = get_perfil_camera(_id_estacion)

	if _transform != null:
		go_to_mini_site(_transform)
		
func on_agregar_poi_particular(_tipo_poi: TIPO_POI.ENUM_POI, _transform: Transform3D):
	camaras_particular[_tipo_poi] = _transform
	
func on_agregar_poi_perfil(_id_estacion: int, _transform: Transform3D):
	if !camaras_perfil.has(_id_estacion):
		camaras_perfil[_id_estacion] = {}

	camaras_perfil[_id_estacion] = _transform
	
func _on_unload_perfil():
	camaras_perfil = {}
	
func _on_unload_particular():
	camaras_particular = {}

func get_poi_camera(tipo: TIPO_POI.ENUM_POI) -> Transform3D:
	return camaras_particular[tipo]

func get_perfil_camera(_id_estacion: int) -> Transform3D:
	return camaras_perfil[_id_estacion]

func go_to_mini_site(_transform: Transform3D):
	if !GlobalSignals.isTransitioning:
		GlobalSignals.isTransitioning = true;
		
		_transform.origin.y = clamp(_transform.origin.y, GlobalData.min_zoom, GlobalData.max_zoom)
		
		var current_camera = get_viewport().get_camera_3d()
		await get_tween().tween_property(current_camera,"global_transform",_transform,  transition_time).finished
		GlobalSignals.isTransitioning = false
		
func go_to_poi_particular(_transform: Transform3D):
	if !GlobalSignals.isTransitioning:
		GlobalSignals.isTransitioning = true;
		
		var current_camera = get_viewport().get_camera_3d()
		await get_tween().tween_property(current_camera,"global_transform",_transform,  transition_time).finished
		GlobalSignals.isTransitioning = false
		
func get_tween()->Tween:
	var tween = create_tween().set_parallel(true) 
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	return tween;
