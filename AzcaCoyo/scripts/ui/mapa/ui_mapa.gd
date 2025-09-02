extends Node

@export var scene_row_mapa: PackedScene

@onready var header_particular_container = %header_particular_container
@onready var perfil_container = %perfil_container
@onready var reset_container = %reset_container

@onready var container: VBoxContainer = %VBoxContainer
@onready var panel_lista_mapa: Panel = %panel_lista_mapa
@onready var tr_btn_esconder: TextureRect = %tr_btn_esconder
@onready var btn_esconder_lista: Button = $panel_lista_mapa/btn_esconder_lista

@onready var ui_graficador = %UiGraficador
@onready var arranque_paro = %ArranqueParo

@onready var control_texture = %ControlTexture
@onready var graficador_texture = %GraficadorTexture

const UMBRAL_SINGLE_CLICK := 0.25

var isParticular: bool = false
var transition_time: float = 0.75;
var tiempo_click: float = 0.0
var hiden_panel: bool = false
var canHidden: bool = true
var tween_actual: Tween
var alpha: float = 0

const bombas_coor := {
	true: Rect2(1589, 1177, 95, 120),
	false: Rect2(1429, 1177, 95, 120)
}

const graficador_coor := {
	true: Rect2(1589, 1336, 95, 94),
	false: Rect2(1429, 1336, 95, 94)
}

func _ready() -> void:
	for proyecto in [23, 22]:
		var instanced_scene = scene_row_mapa.instantiate()
		instanced_scene.inicializar_row(proyecto);
		container.add_child(instanced_scene);

	GlobalSignals.connect_on_camera_leave_initial_position(_on_camera_leave_initial_position, true)
	GlobalSignals.connect_on_camera_reset_position(_on_camera_reset_position, true)
	GlobalSignals.connect_on_mini_site_clicked(_on_mini_site_clicked, true)
	GlobalSignals.connect_on_go_perfil_particular(_set_perfil_reset, true)

func _exit_tree() -> void:
	GlobalSignals.connect_on_camera_leave_initial_position(_on_camera_leave_initial_position, false)
	GlobalSignals.connect_on_camera_reset_position(_on_camera_reset_position, false)
	GlobalSignals.connect_on_mini_site_clicked(_on_mini_site_clicked, false)
	GlobalSignals.connect_on_go_perfil_particular(_set_perfil_reset, false)

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
	hiden_panel = false
	btn_esconder_lista.z_index = 2
	_mostrarTabla()

func get_container_size(_container: Control) -> float:
	return _container.get_combined_minimum_size().y

func _on_mini_site_clicked(_id_estacion: int, _id_proyecto: int):
	if _id_estacion == 0 && _id_proyecto == 0:
		_moverPanel(arranque_paro, ui_graficador, 1105.0, -1100.0, 0.0)
		control_texture.texture.set('region', bombas_coor[false])
		graficador_texture.texture.set('region', graficador_coor[false])
		canHidden = true
	if _id_estacion != 0:
		#btn_esconder_lista.z_index = 0;
		hiden_panel = false
		_mostrarTabla()

func _mostrarTabla():
	get_tween().tween_property(panel_lista_mapa, "position", Vector2(0, 980), transition_time)
	get_tween().tween_property(tr_btn_esconder, "rotation_degrees", 90, transition_time)

func _on_button_header_gui_input(event: InputEvent) -> void:
	if canHidden:
		if event is InputEventMouseButton and event.is_pressed():
			tiempo_click = Time.get_ticks_msec() / 1000.0
		if event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
			var tiempo_actual = Time.get_ticks_msec() / 1000.0
			var intervalo = tiempo_actual - tiempo_click

			if intervalo < UMBRAL_SINGLE_CLICK:
				if hiden_panel && canHidden:
					_on_camera_reset_position()
				else:
					_on_camera_leave_initial_position()

func _moverPanel(canvaGraficador: Control, canvaCBomba: Control, _graficadorPosition: float, _cBombaPosition: float, _alpha: float):
	var graficadorPosition = Vector2(_graficadorPosition, canvaGraficador.position.y)
	var cBombaPosition = Vector2(_cBombaPosition, canvaCBomba.position.y)
	alpha = _alpha

	if tween_actual and tween_actual.is_running():
		tween_actual.kill()

	tween_actual = create_tween()
	tween_actual.set_ease(Tween.EASE_IN_OUT)
	tween_actual.set_trans(Tween.TRANS_SINE)
	tween_actual.parallel().tween_property(canvaGraficador, "position", graficadorPosition, 0.3)
	tween_actual.parallel().tween_property(canvaCBomba, "position", cBombaPosition, 0.3)
	tween_actual.tween_callback(_showButtons)

	await tween_actual.finished
	tween_actual.kill()
	tween_actual = null

func _showButtons():
	arranque_paro.showButtos(alpha)

func _set_texture_buttons(control: bool, graficador: bool):
	control_texture.texture.set('region', bombas_coor[control])
	graficador_texture.texture.set('region', graficador_coor[graficador])

func _set_perfil_reset(_show: bool, _id_estacion: int, _id_proyecto: int):
	perfil_container.visible = _show
	header_particular_container.visible = _show
	reset_container.visible = !_show
	control_texture.texture.set('region', bombas_coor[false])
	graficador_texture.texture.set('region', graficador_coor[false])
	
	if !_show:
		GlobalSignals.on_mini_site_clicked.emit(0, 0)
	else:
		_moverPanel(arranque_paro, ui_graficador, 1105.0, -1100.0, 0.0)

func _on_button_reset_pressed() -> void:
	canHidden = true
	GlobalSignals.on_mini_site_clicked.emit(0, 0)
	_on_camera_reset_position()
	_set_texture_buttons(false, false)
	_moverPanel(arranque_paro, ui_graficador, 1105.0, -1100.0, 0.0)

func _on_button_arranque_paro_pressed() -> void:
	canHidden = false
	_on_camera_reset_position()
	_set_texture_buttons(true, false)
	_moverPanel(arranque_paro, ui_graficador, 104.0, -1100.0, 1.0)

func _on_button_graficador_pressed() -> void:
	canHidden = false
	_on_camera_reset_position()
	_set_texture_buttons(false, true)
	_moverPanel(arranque_paro, ui_graficador, 1105.0, 0.0, 0.0)

func _on_go_to_perfil_pressed():
	GlobalSceneManager.load_perfil()
	GlobalSignals.on_go_perfil_particular.emit(false, 0, 0)
