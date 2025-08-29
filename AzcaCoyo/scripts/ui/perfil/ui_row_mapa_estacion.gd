extends Control

@onready var id: Label = %ID
@onready var name_site: Label = %Name_site
@onready var pressure = %Pressure
@onready var in_line = %inLine

@onready var date_date = %Date_Date
@onready var date_time = %Date_Time


@onready var site_selected = %SiteSelected

var estacion: Estacion
var id_Estacion: int
var id_Proyecto: int
var id_Pressure: int

var mapa_acentos = {
		"á": "a", "é": "e", "í": "i", "ó": "o", "ú": "u",
		"Á": "A", "É": "E", "Í": "I", "Ó": "O", "Ú": "U"
	}

const alarmado_coor := {
	false: Rect2(159, 190, 50, 50),  # rojo
	true: Rect2(213, 190, 50, 50),  # verde
}

const UMBRAL_SINGLE_CLICK := 0.25
var tiempo_click: float = 0.0
var canZoom: bool = true

func _ready():
	id.text = str(estacion.id_estacion)
	name_site.text = estacion.nombre
	GlobalSignals.connect_on_update_app(_on_update_app, true)
	GlobalSignals.connect_on_mini_site_clicked(_on_Site_Click, true)
	GlobalSignals.connect_on_row_site_clicked_at_particular(_on_Site_Click, true)
	GlobalSignals.connect_on_go_perfil_particular(_set_perfil_reset, true)
	_on_update_app()

func inicializar_row(_estacion: Estacion):
	estacion = _estacion
	id_Estacion = estacion.id_estacion
	id_Proyecto = estacion.id_proyecto
	for _signal: Señal in estacion.signals.values():
		if _signal.tipo_signal == TIPO_SIGNAL.Tipo_Signal.Presion:
			id_Pressure = _signal.id_signal

func _on_update_app() -> void:
	estacion = GlobalData.get_estacion(id_Estacion, id_Proyecto)
	pressure.text = str(estacion.signals.get(id_Pressure).get_valor_string())
	date_date.text = GlobalUtils.formatear_date_date(estacion.tiempo)
	date_time.text = GlobalUtils.formatear_date_time(estacion.tiempo)
	in_line.texture.set('region', alarmado_coor[estacion.is_estacion_en_linea()])

func _on_Site_Click(_id_estacion: int, _id_proyecto: int):
	var select: bool = _id_estacion == id_Estacion && _id_proyecto == id_Proyecto
	site_selected.visible = select

func _on_button_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		tiempo_click = Time.get_ticks_msec() / 1000.0
		GlobalSignals.on_desactivar_eventos.emit(true)
	if event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
		_manejar_click()
		GlobalSignals.on_desactivar_eventos.emit(false)

func _set_perfil_reset(_perfil: bool):
	canZoom = !_perfil

func _manejar_click():
	var tiempo_actual = Time.get_ticks_msec() / 1000.0
	var intervalo = tiempo_actual - tiempo_click
	if intervalo < UMBRAL_SINGLE_CLICK:
		if canZoom:
			GlobalSignals.on_mini_site_clicked.emit(id_Estacion, id_Proyecto)
		else:
			GlobalSignals.on_row_site_clicked_at_particular.emit(id_Estacion, id_Proyecto)

func _on_button_go_to_particular(event):
	if event is InputEventMouseButton and event.is_pressed():
		tiempo_click = Time.get_ticks_msec() / 1000.0
		GlobalSignals.on_desactivar_eventos.emit(true)
	if event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
		_go_to_particular()
		GlobalSignals.on_desactivar_eventos.emit(false)

func _go_to_particular():
	var tiempo_actual = Time.get_ticks_msec() / 1000.0
	var intervalo = tiempo_actual - tiempo_click

	if intervalo < UMBRAL_SINGLE_CLICK:
		#var nombre_sitio = estacion.nombre.replace(" ", "_").replace(".","")
		GlobalSceneManager.load_particular("ParticularParent") # Ir a
		GlobalSignals.on_go_perfil_particular.emit(true)
		site_selected.visible = true
		_manejar_click()
