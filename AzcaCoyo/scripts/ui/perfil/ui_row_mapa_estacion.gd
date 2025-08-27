extends Control

@onready var id: Label = %ID
@onready var name_site: Label = %Name_site
@onready var date: Label = %Date
@onready var pressure = %Pressure
@onready var in_line = %inLine

@onready var site_selected = %SiteSelected

var estacion: Estacion
var id_Estacion: int
var id_Proyecto: int
var id_Pressure: int

var mapa_acentos = {
		"á": "a", "é": "e", "í": "i", "ó": "o", "ú": "u",
		"Á": "A", "É": "E", "Í": "I", "Ó": "O", "Ú": "U",
		"à": "a", "è": "e", "ì": "i", "ò": "o", "ù": "u",
		"À": "A", "È": "E", "Ì": "I", "Ò": "O", "Ù": "U",
		"ä": "a", "ë": "e", "ï": "i", "ö": "o", "ü": "u",
		"Ä": "A", "Ë": "E", "Ï": "I", "Ö": "O", "Ü": "U",
		"ñ": "n", "Ñ": "N",
		"ç": "c", "Ç": "C"
	}

const alarmado_coor := {
	false: Rect2(159, 190, 50, 50),  # rojo
	true: Rect2(213, 190, 50, 50),  # verde
}

const UMBRAL_SINGLE_CLICK := 0.25
var tiempo_click: float = 0.0

func _ready():
	id.text = str(estacion.id_estacion)
	name_site.text = estacion.nombre
	GlobalSignals.connect_on_update_app(_on_update_app, true)
	GlobalSignals.connect_on_mini_site_clicked(_on_Site_Click, true)
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
	date.text = GlobalUtils.formatear_fecha(estacion.tiempo)
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

func _manejar_click():
	var tiempo_actual = Time.get_ticks_msec() / 1000.0
	var intervalo = tiempo_actual - tiempo_click

	if intervalo < UMBRAL_SINGLE_CLICK:
		GlobalSignals.on_mini_site_clicked.emit(id_Estacion, id_Proyecto)

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
		var nombre_sitio = estacion.nombre.replace(" ", "_").replace(".","")
		print("ir a ", nombre_sitio)
		_manejar_click()
		GlobalSceneManager.load_particular("ParticularParent") # Ir a
