extends Node

@export var scene_row_mapa_estacion: PackedScene
@onready var sites_container = %SitesContainer
@onready var color_interceptor: TextureRect = %color_interceptor
@onready var lbl_nombre_interceptor: Label = %lbl_nombre_interceptor
@onready var lbl_total_online: Label = %lbl_total_online
@onready var lbl_total_offline: Label = %lbl_total_offline
@onready var tr_seleccion: TextureRect = %tr_seleccion

var id_estaciones: Array[int]
var estaciones: Array[Estacion]
var id_proyecto: int
var proyecto_name: String;
var online_count: int;

const UMBRAL_SINGLE_CLICK := 0.25
var tiempo_click: float = 0.0

func inicializar_row(_id_proyecto: int):
	id_proyecto = _id_proyecto
	
func _ready() -> void:
	proyecto_name = GlobalData.get_name_interceptor(id_proyecto)
	lbl_nombre_interceptor.text = proyecto_name;
	color_interceptor.modulate = GlobalData.get_color_interceptor(id_proyecto);
	
	var _estaciones = GlobalData.get_all_data();
	
	for estacion: Estacion in _estaciones:
		if estacion.id_proyecto == id_proyecto:
			var instanced_scene = scene_row_mapa_estacion.instantiate()
			instanced_scene.inicializar_row(estacion);
			sites_container.add_child(instanced_scene);
			id_estaciones.append(estacion.id_estacion);
			estaciones.append(estacion)
			
	if id_estaciones.size() == 0:
		self.queue_free();
	else:
		GlobalSignals.connect_on_update_app(_on_update_app, true)
		GlobalSignals.connect_on_mini_site_clicked(_on_mini_site_clicked, true)

		_on_update_app()

func _exit_tree() -> void:
	GlobalSignals.connect_on_update_app(_on_update_app, false)
	GlobalSignals.connect_on_mini_site_clicked(_on_mini_site_clicked, false)

func _on_update_app():
	online_count = 0;
	var _estaciones = GlobalData.get_all_data();

	for estacion: Estacion in _estaciones:
		if estacion.id_proyecto == id_proyecto:
			online_count += 1 if estacion.is_estacion_en_linea() else 0

	lbl_total_online.text = str(online_count);
	lbl_total_offline.text = str(id_estaciones.size() - online_count);


func _on_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		tiempo_click = Time.get_ticks_msec() / 1000.0
		GlobalSignals.on_desactivar_eventos.emit(true)
	if event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
		_manejar_click()
		GlobalSignals.on_desactivar_eventos.emit(false)

func _manejar_click():
	var tiempo_actual = Time.get_ticks_msec() / 1000.0
	var intervalo = tiempo_actual - tiempo_click
	
	if intervalo < UMBRAL_SINGLE_CLICK:
		GlobalSignals.on_mini_site_clicked.emit(-id_proyecto);

func _on_mini_site_clicked(_id: int):
	if _id == 0:
		return;
		
	tr_seleccion.visible = _id == id_proyecto;
