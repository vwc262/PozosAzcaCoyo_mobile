extends Node

@export var scene_lista_sitio: PackedScene

@onready var elemento_panel: Control = $"."  # Nodo raíz de la tarjeta/lista
@onready var lbl_nombre_sitio: Label = %lbl_nombre_sitio
@onready var arrow_select = %arrow_select
@onready var color_interceptor = %color_interceptor
@onready var contenedor_datos: PanelContainer = %datos_sitios_ramal
@onready var datos_sitios_contenedor: VBoxContainer = %datos_sitios_contenedor
@onready var temporizador_click: Timer = %temporizador_click

@onready var lbl_total_online: Label = %lbl_total_online
@onready var lbl_total_offline: Label = %lbl_total_offline
@onready var ui_lista_alarmados = %UiListaAlarmados

var total_sitios: int

# Alturas
const ALTURA_BASE := 100.0
var altura_contenido: float = 0.0

# Doble clic
const UMBRAL_DOBLE_CLICK := 0.2
var tiempo_ultimo_click: float = 0.0

# clic
const UMBRAL_SINGLE_CLICK := 0.35
var tiempo_click: float = 0.0

# Estado
var esta_expandido: bool = false
var tween_actual: Tween
var estaciones: Array[Estacion]

var nombre: String = ""

func _ready() -> void:
	_limpiar_lista()
	#await get_tree().process_frame  # Asegura que layout esté listo
	temporizador_click.one_shot = true
	temporizador_click.wait_time = UMBRAL_DOBLE_CLICK
	temporizador_click.timeout.connect(_on_click_simple_confirmado)
	GlobalSignals.connect_on_update_app(_on_update, true)

func _exit_tree() -> void:
	GlobalSignals.connect_on_update_app(_on_update, false)

func set_estacion_data(estaciones_data: Array[Estacion]) -> void:
	estaciones = estaciones_data
	total_sitios = estaciones.size()
	ui_lista_alarmados.set_data_estacion(estaciones)
	_append_ramales_lista()
	_on_update()
	altura_contenido = contenedor_datos.get_combined_minimum_size().y

func set_nombre_interceptor(_nombre: String) -> void:
	nombre = _nombre
	lbl_nombre_sitio.text = nombre

func set_color_interceptor(color: Color) -> void:
	color_interceptor.modulate = color

func _limpiar_lista() -> void:
	for child in datos_sitios_contenedor.get_children():
		child.queue_free()

func _append_ramales_lista() -> void:
	for estacion: Estacion in estaciones:
		var elemento:= scene_lista_sitio.instantiate()
		if not elemento is Control:
			push_error("La escena instanciada no es un nodo de tipo Control")
			continue

		datos_sitios_contenedor.add_child(elemento)
		elemento.set_data_estacion(estacion)

func _on_btn_elemento_lista_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		tiempo_click = Time.get_ticks_msec() / 1000.0
	if event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
		_manejar_click(event)

func _manejar_click(_event: InputEventMouseButton) -> void:
	var tiempo_actual = Time.get_ticks_msec() / 1000.0
	var intervalo = tiempo_actual - tiempo_ultimo_click

	if intervalo < UMBRAL_DOBLE_CLICK:
		temporizador_click.stop()
		_on_doble_click()
		tiempo_ultimo_click = 0.0
	else:
		temporizador_click.start()
		tiempo_ultimo_click = tiempo_actual

func _on_click_simple_confirmado() -> void:
	var tiempo_actual = Time.get_ticks_msec() / 1000.0
	var intervalo = tiempo_actual - tiempo_click
	
	if intervalo < UMBRAL_SINGLE_CLICK:
		_alternar_expansion()

func _on_doble_click() -> void:
	print("Doble clic")
	# Lógica adicional si quieres reaccionar distinto al doble clic

func _alternar_expansion() -> void:
	var nueva_altura = ALTURA_BASE if esta_expandido else ALTURA_BASE + altura_contenido
	esta_expandido = !esta_expandido
	arrow_select.rotation_degrees = -90.0 if esta_expandido else 90.0

	if tween_actual and tween_actual.is_running():
		tween_actual.kill()

	tween_actual = create_tween()
	tween_actual.set_ease(Tween.EASE_IN_OUT)
	tween_actual.set_trans(Tween.TRANS_SINE)
	tween_actual.tween_property(elemento_panel, "custom_minimum_size:y", nueva_altura, 0.3)

	await tween_actual.finished
	tween_actual.kill()
	tween_actual = null

func colapsar() -> void:
	if esta_expandido:
		_alternar_expansion()

func _on_update() -> void:
	var total_online = GlobalData.get_total_online(estaciones)
	var total_offline = total_sitios - total_online
	lbl_total_online.text = str(total_online)
	lbl_total_offline.text = str(total_offline)
