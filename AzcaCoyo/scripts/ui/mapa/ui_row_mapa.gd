extends Node

@export var scene_row_mapa_estacion: PackedScene

@onready var sites_container = %SitesContainer

@onready var color_interceptor: TextureRect = %color_interceptor
@onready var lbl_nombre_interceptor: Label = %lbl_nombre_interceptor
@onready var lbl_total_online: Label = %lbl_total_online
@onready var lbl_total_offline: Label = %lbl_total_offline
@onready var tr_seleccion: TextureRect = %tr_seleccion
@onready var container = $"."

# Estado
var esta_expandido: bool = false
var tween_actual: Tween

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
		proyecto_name = proyecto_name;

		GlobalSignals.connect_on_update_app(_on_update_app, true)
		GlobalSignals.connect_on_click_interceptor(_on_click_interceptor, true)

		_on_update_app()

func _exit_tree() -> void:
	GlobalSignals.connect_on_update_app(_on_update_app, false)
	GlobalSignals.connect_on_click_interceptor(_on_click_interceptor, false)

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
	esta_expandido = !esta_expandido
	var nueva_altura = 356 if esta_expandido else 100
	
	#if intervalo < UMBRAL_SINGLE_CLICK:
		#GlobalSignals.on_click_interceptor.emit(proyecto_name);
	GlobalSignals.on_click_interceptor.emit(proyecto_name);
		#tr_seleccion.visible = true;
		
	if tween_actual and tween_actual.is_running():
		tween_actual.kill()

	tween_actual = create_tween()
	tween_actual.set_ease(Tween.EASE_IN_OUT)
	tween_actual.set_trans(Tween.TRANS_SINE)
	tween_actual.tween_property(container, "custom_minimum_size:y", nueva_altura, 0.3)

	await tween_actual.finished
	tween_actual.kill()
	tween_actual = null

func _on_click_interceptor(_proyecto_name: String):
	#if _proyecto_name == "NA":
		#return;
	if _proyecto_name == proyecto_name:
		pass
	tr_seleccion.visible = false;
