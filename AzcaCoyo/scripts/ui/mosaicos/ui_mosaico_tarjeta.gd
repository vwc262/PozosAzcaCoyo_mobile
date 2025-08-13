extends Node

@onready var tarjeta_panel: Panel = $"." 
@onready var contenedor_datos: Panel = %datos_container
@onready var temporizador_click: Timer = %Timer
@onready var lbl_nombre_sitio: Label = %lbl_nombre_sitio
@onready var tr_enlace: TextureRect = %tr_enlace
@onready var lbl_nombre_nivel: Label = %lbl_nombre_nivel
@onready var lbl_valor_nivel: Label = %lbl_valor_nivel
@onready var lbl_fecha_sitio: Label = %lbl_fecha_sitio
@onready var tr_render = %tr_render
@onready var tr_alerta: ColorRect = %cr_alerta
@onready var tr_alerta_material: Material = %cr_alerta.material
@onready var tr_selected: TextureRect = %tr_selected

# Alturas para expandido y colapsado
const ALTURA_COLAPSADA := 25
const ALTURA_EXPANDIDA := 60

# Tiempo máximo entre clics para considerar doble clic (segundos)
const UMBRAL_DOBLE_CLICK := 0.2
const UMBRAL_SINGLE_CLICK := 0.35

# Estado actual
var esta_expandida: bool = false
var tween_actual: Tween
var tiempo_ultimo_click: float = 0.0
var tiempo_click: float = 0.0

var estacion: Estacion;
var nivel: Señal;
var alerta: TIPO_ALERTA.ENUM_ALERTA
var particular_name: String;
var color_alertado: Color;
var alpha_progress: float = 0.0;

var columnas: int = 7
var filas: float = 6.0
var color_seleccion: Color;

func initialize(_estacion: Estacion):
	estacion = _estacion	

func _ready() -> void:
	var regex = RegEx.new()
	regex.compile("[^\\wáéíóúÁÉÍÓÚñÑüÜ]")  # Elimina todo menos lo especificado
	
	lbl_nombre_sitio.text = estacion.abreviacion
	particular_name = "{0}_{1}".format([str(estacion.id_estacion).pad_zeros(2), regex.sub(estacion.abreviacion.to_lower(), "", true) ])
	
	for _signal in estacion.signals.values():
		if _signal.tipo_signal == TIPO_SIGNAL.Tipo_Signal.Nivel and _signal.ordinal == 0:
			nivel = _signal;
			break;
	
	lbl_nombre_nivel.text = nivel.nombre;
	color_seleccion = GlobalData.get_color_interceptor(estacion.tipo_interceptor)
	
	var w = 190;
	var h = 160;
	var x = ((estacion.id_estacion - 1) % columnas) * w;
	var y = floor((estacion.id_estacion - 1) / (filas + 1.0)) * h;
	tr_render.texture.set('region', Rect2(x, y, w, h))
	
	temporizador_click.one_shot = true
	temporizador_click.wait_time = UMBRAL_DOBLE_CLICK
	temporizador_click.timeout.connect(_on_click_simple_confirmado)
	
	GlobalSignals.connect_on_update_app(_on_update_app, true)
	GlobalSignals.connect_on_tarjeta_mosaico_clicked(_on_tarjeta_mosaico_clicked, true)
	_on_update_app()
	
func _exit_tree() -> void:
	GlobalSignals.connect_on_update_app(_on_update_app, false)
	GlobalSignals.connect_on_tarjeta_mosaico_clicked(_on_tarjeta_mosaico_clicked, false)
	
func _on_update_app():
	estacion = GlobalData.get_estacion(estacion.id_estacion);
	
	alerta = GlobalData.get_estado_alarmado(estacion);
	if alerta == TIPO_ALERTA.ENUM_ALERTA.NORMAL:
		tr_alerta.visible = false;
	else:
		tr_alerta.visible = true;
		tr_alerta_material.set_shader_parameter("edge_color", GlobalData.get_color_estdado_alertado(estacion))
	
	lbl_fecha_sitio.text = GlobalUtils.formatear_fecha(estacion.tiempo)
	tr_enlace.modulate = estacion.get_color_enlace()
	
	nivel = estacion.signals.get(nivel.id_signal)
	lbl_valor_nivel.text = nivel.get_valor_string();

func _on_btn_tarjeta_gui_input(event: InputEvent) -> void:
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
		GlobalSignals.on_tarjeta_mosaico_clicked.emit(estacion.id_estacion);

func _on_doble_click() -> void:
	GlobalData.selected_particular = estacion.id_estacion;
	GlobalSceneManager.load_particular(particular_name)
	GlobalUiManager.mostrar_modulo(TIPO_MODULO.UI.PARTICULAR);

func _on_tarjeta_mosaico_clicked(_id_estacion:int):
	if _id_estacion == estacion.id_estacion:
		tr_selected.visible = true;
		tr_selected.modulate = color_seleccion
	else:
		tr_selected.visible = false;
