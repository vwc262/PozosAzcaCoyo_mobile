extends Node

@export var scene_row_mapa: PackedScene

@onready var container: VBoxContainer = %VBoxContainer
@onready var panel_lista_mapa: Panel = %panel_lista_mapa
@onready var tr_btn_esconder: TextureRect = %tr_btn_esconder
@onready var btn_esconder_lista: Button = $panel_lista_mapa/btn_esconder_lista

const UMBRAL_SINGLE_CLICK := 0.25

var transition_time: float = 0.75;
var tiempo_click: float = 0.0

var hiden_panel: bool = false;

func _ready() -> void:
	for proyecto in [23, 22]:
		var instanced_scene = scene_row_mapa.instantiate()
		instanced_scene.inicializar_row(proyecto);
		container.add_child(instanced_scene);

	GlobalSignals.connect_on_camera_leave_initial_position(_on_camera_leave_initial_position, true)
	GlobalSignals.connect_on_camera_reset_position(_on_camera_reset_position, true)
	GlobalSignals.connect_on_mini_site_clicked(_on_mini_site_clicked, true)
	
func _exit_tree() -> void:
	GlobalSignals.connect_on_camera_leave_initial_position(_on_camera_leave_initial_position, false)
	GlobalSignals.connect_on_camera_reset_position(_on_camera_reset_position, false)
	GlobalSignals.connect_on_mini_site_clicked(_on_mini_site_clicked, false)

func get_tween():
	var tween = create_tween().set_parallel(true) 
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	return tween;

func _on_camera_leave_initial_position():
	hiden_panel = true;
	get_tween().tween_property(tr_btn_esconder, "rotation_degrees", -90, transition_time)
	#get_tween().tween_property(panel_lista_mapa, "position", Vector2(0, 980 + get_container_size(panel_lista_mapa) + 10), transition_time)
	get_tween().tween_property(panel_lista_mapa, "position", Vector2(0, 1854.0), transition_time)
	btn_esconder_lista.z_index = 2;

func _on_camera_reset_position():
	hiden_panel = false;
	get_tween().tween_property(tr_btn_esconder, "rotation_degrees", 90, transition_time)
	get_tween().tween_property(panel_lista_mapa, "position", Vector2(0, 980), transition_time)
	btn_esconder_lista.z_index = 2;

func get_container_size(_container: Control) -> float:
	return _container.get_combined_minimum_size().y

func _on_mini_site_clicked(_id_estacion: int, _id_proyecto: int):pass
	#if _id_estacion != 0:
		#
		#btn_esconder_lista.z_index = 0;
		#get_tween().tween_property(panel_lista_mapa, "position", Vector2(0, 1960), transition_time)

func _on_button_pressed():
	GlobalSignals.on_mini_site_clicked.emit(0, 0)
	_on_camera_reset_position()

func _on_button_header_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		tiempo_click = Time.get_ticks_msec() / 1000.0
	if event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
		var tiempo_actual = Time.get_ticks_msec() / 1000.0
		var intervalo = tiempo_actual - tiempo_click
	
		if intervalo < UMBRAL_SINGLE_CLICK:
			if hiden_panel:
				_on_camera_reset_position()
			else:
				_on_camera_leave_initial_position()
