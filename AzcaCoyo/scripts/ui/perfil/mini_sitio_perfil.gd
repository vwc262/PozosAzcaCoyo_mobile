extends Node3D

@onready var poi: Camera3D = %POI
@onready var etiqueta_perfil_3d: Node3D = $Etiqueta_Perfil_3D
@onready var sphere: MeshInstance3D = $Etiqueta_Perfil_3D/Sphere
@onready var lbl_id: Label3D = %lbl_id
@onready var lbl_id2: Label3D = %lbl_id2
@onready var mimico_container: Node3D = %mimico_container
@onready var icono_3d_base_b: Node3D = %Icono3D_Base_b

@export var min_scale: float = 0.1;
@export var max_scale: float = 0.45;

var id_estacion: int
var estacion: Estacion;
var id_proyecto: int;
var initial_position: Vector3;
var signal_bomba: Señal;

var camera3D: Camera3D;
var min_distance: float = 0.25
var max_distance: float = 20.0

const UMBRAL_SINGLE_CLICK := 0.25
var tiempo_click: float = 0.0
var rotate_speed: float = 1.0;

var do_rotate:bool = false;

@onready var pozo = preload("res://scenes/minis/pozo.tscn")
@onready var etiqueta_perfil_mat: Material = %Etiqueta_Perfil_3D.get_node("Sphere").get_surface_override_material(0)
@onready var bomba_azcacoyo_mat: Material = %Bomba_Azcacoyo_01.get_child(0).material_override

func initialize(_id_estacion: int, _id_proyecto: int):
	id_estacion = _id_estacion
	id_proyecto = _id_proyecto

func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		tiempo_click = Time.get_ticks_msec() / 1000.0
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		var tiempo_actual = Time.get_ticks_msec() / 1000.0
		var intervalo = tiempo_actual - tiempo_click
	
		if intervalo < UMBRAL_SINGLE_CLICK:
			GlobalSignals.on_mini_site_clicked.emit(id_estacion, id_proyecto)

func _ready() -> void:
	lbl_id.text = str(id_estacion)
	lbl_id2.text = str(id_estacion)
	estacion = GlobalData.get_estacion(id_estacion, id_proyecto);
	id_proyecto = estacion.id_proyecto;
	
	for _signal: Señal in estacion.signals.values():
		if _signal.tipo_signal == TIPO_SIGNAL.Tipo_Signal.Bomba:
			signal_bomba = _signal
	
	camera3D = get_viewport().get_camera_3d()
	initial_position = camera3D.global_position;
	
	var mini_instanced = pozo.instantiate()
	
	mimico_container.add_child(mini_instanced);
	
	GlobalSignals.on_agregar_poi_perfil.emit(id_estacion, id_proyecto, poi.global_transform);
	GlobalSignals.connect_on_mini_site_clicked(_on_mini_site_clicked, true)
	GlobalSignals.connect_on_update_app(_on_update_app, true)
	
	_on_update_app()
	
func _process(_delta: float) -> void:
	var distance = initial_position.distance_to(camera3D.global_position)
	
	var t = remap(distance, min_distance, max_distance, 0, 1)
	var w = exp(-4 * t)
	etiqueta_perfil_3d.scale = Vector3.ONE * clamp(lerp(min_scale, max_scale, w), min_scale, max_scale)
	
	if do_rotate:
		icono_3d_base_b.rotate_y(_delta * rotate_speed)

func _exit_tree() -> void:
	GlobalSignals.connect_on_mini_site_clicked(_on_mini_site_clicked, false)
	GlobalSignals.connect_on_update_app(_on_update_app, false)

func _on_mini_site_clicked(_id_estacion: int, _id_proyecto: int):
	do_rotate = id_estacion == _id_estacion && id_proyecto == _id_proyecto

func _on_update_app():
	estacion = GlobalData.get_estacion(id_estacion, id_proyecto);
	signal_bomba = estacion.signals.get(signal_bomba.id_signal);
	
	var color = signal_bomba.get_color_bomba_vec4()
	
	bomba_azcacoyo_mat.set_shader_parameter("albedo", color)
	etiqueta_perfil_mat.set_shader_parameter("albedo", color)
