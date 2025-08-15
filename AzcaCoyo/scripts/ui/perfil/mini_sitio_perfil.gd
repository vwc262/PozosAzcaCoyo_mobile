extends Node3D

@onready var poi: Camera3D = %POI
@onready var etiqueta_perfil_3d: Node3D = $Etiqueta_Perfil_3D
@onready var sphere: MeshInstance3D = $Etiqueta_Perfil_3D/Sphere
@onready var lbl_id: Label3D = %lbl_id
@onready var mimico_container: Node3D = %mimico_container
@onready var icono_3d_base_b: Node3D = %Icono3D_Base_b

@export var min_scale: float = 0.6;
@export var max_scale: float = 1.8;

var id_estacion: int
var estacion: Estacion;
var id_proyecto: int;
var initial_position: Vector3;

var camera3D: Camera3D;
var min_distance: float = 1.0
var max_distance: float = 4.0

const UMBRAL_SINGLE_CLICK := 0.25
var tiempo_click: float = 0.0
var rotate_speed: float = 1.0;

var do_rotate:bool = false;

@onready var pozo = preload("res://scenes/minis/pozo.tscn")

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
			GlobalSignals.on_mini_site_clicked.emit(id_estacion)

func _ready() -> void:
	lbl_id.text = str(id_estacion)
	estacion = GlobalData.get_estacion(id_estacion, id_proyecto);
	id_proyecto = estacion.id_proyecto;
	
	camera3D = get_viewport().get_camera_3d()
	initial_position = camera3D.global_position;
	#max_distance = initial_position.distance_to(global_position)
	
	var mini_instanced = pozo.instantiate()
	
	mimico_container.add_child(mini_instanced);
	
	GlobalSignals.on_agregar_poi_perfil.emit(id_estacion, poi.global_transform);
	GlobalSignals.connect_on_click_interceptor(_on_click_interceptor, true)
	GlobalSignals.connect_on_mini_site_clicked(_on_mini_site_clicked, true)
	
func _process(_delta: float) -> void:
	var distance = initial_position.distance_to(camera3D.global_position)
	
	var t = inverse_lerp(max_distance, min_distance, distance)
	etiqueta_perfil_3d.scale = Vector3.ONE * lerp(min_scale, max_scale, t)
	
	if do_rotate:
		icono_3d_base_b.rotate_y(_delta * rotate_speed)

func _exit_tree() -> void:
	GlobalSignals.connect_on_click_interceptor(_on_click_interceptor, false)
	GlobalSignals.connect_on_mini_site_clicked(_on_mini_site_clicked, false)
	
func _on_click_interceptor(_interceptor_abreviacion: String): pass
	#if _interceptor_abreviacion == estacion.abreviacion_interceptor:
		#sphere.get_surface_override_material(0)["shader_parameter/albedo"] = GlobalData.get_color_interceptor(interceptor)
		#perfil_poste.get_surface_override_material(0)["shader_parameter/albedo"] = GlobalData.get_color_interceptor(interceptor)
	#else:
		#sphere.get_surface_override_material(0)["shader_parameter/albedo"] = Color(0.09, 0.43, 1.0, 1.0)
		#perfil_poste.get_surface_override_material(0)["shader_parameter/albedo"] = Color(0.09, 0.43, 1.0, 1.0)
	
	#etiqueta_perfil_3d.visible = _interceptor_abreviacion == "NA" or _interceptor_abreviacion == estacion.abreviacion_interceptor
	
func _on_mini_site_clicked(_id_estacion: int):
	do_rotate = id_estacion == _id_estacion
