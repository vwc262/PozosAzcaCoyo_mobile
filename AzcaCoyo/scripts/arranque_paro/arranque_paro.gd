extends Node

@onready var http_request: HTTPRequest = %HTTPRequest
@onready var name_site = %name_site
@onready var tr_bomba: TextureRect = %tr_bomba
@onready var lbl_ejecutando: Label = %lbl_ejecutando
@onready var lbl_perilla_bomba: Label = %lbl_perilla_bomba
@onready var tr_accion: TextureRect = %tr_accion
@onready var tr_ejecutar: TextureRect = %tr_ejecutar
@onready var ejecutar_background: TextureRect = %ejecutar_background
@onready var color_rect_background: ColorRect = %ColorRect_background
@onready var color_rect_loading: ColorRect = %ColorRect_loading
@onready var label: Label = %Label

var id_estacion: int = 0;
var id_proyecto: int = 0;
var id_bomba: int = 0;
var id_perilla: int = 0;
var arrancar: bool = false;
var ejecutar: bool = false;
var estacion: Estacion;
var bomba: Señal;
var perilla: Señal;

const boton_accion := {
	true: Rect2(1343, 1513, 107, 251),
	false: Rect2(1480, 1513, 107, 251),
}

const boton_ejecucion := {
	true: Rect2(1606, 1512, 208, 103),
	false: Rect2(1606, 1625, 208, 103),
}

#region Datos API
var data_to_send: Dictionary = {
	"Usuario": "App_Movil",
	"idEstacion": 0,
	"Codigo": 0,
	"RegModbus": 2020,
};

const HEADERS = ["Content-Type: application/json"]
var uri_reportes: String = "https://virtualwavecontrol.com.mx/Core24/crud/InsertComando?idProyecto="
	
func _ready() -> void:
	GlobalSignals.connect_on_mini_site_clicked(_on_site_row_clicked, true)
	GlobalSignals.connect_on_update_app(_on_update_app, true);
	_on_site_row_clicked(1, 23)
	
func _exit_tree() -> void:
	GlobalSignals.connect_on_mini_site_clicked(_on_site_row_clicked, false)
	GlobalSignals.connect_on_update_app(_on_update_app, false);
	
func _on_update_app() -> void:
	if  id_bomba != 0:
		estacion = GlobalData.get_estacion(id_estacion, id_proyecto);
		bomba = estacion.signals.get(id_bomba);
		perilla = estacion.signals.get(id_perilla);

		tr_bomba.modulate = bomba.get_color_bomba_string();
		lbl_perilla_bomba.text = "REM" if perilla.valor == 1 else "LOC" if perilla.valor == 2 else "OFF"
		
	#anim_ejecutar();

func _on_button_accion_pressed() -> void:
	arrancar = !arrancar
	tr_accion.texture.set("region", boton_accion[arrancar])

	ejecutar = false
	tr_ejecutar.texture.set("region", boton_ejecucion[ejecutar])

	lbl_ejecutando.text = "ARRANCAR" if arrancar else "PARAR"

func _on_button_ejecutar_pressed() -> void:
	ejecutar = !ejecutar
	tr_ejecutar.texture.set("region", boton_ejecucion[ejecutar])

	send_command();

func _on_site_row_clicked(_id_estacion: int, _id_proyecto: int):
	if _id_estacion != 0 && _id_proyecto != 0:
		id_estacion = _id_estacion
		id_proyecto = _id_proyecto

		estacion = GlobalData.get_estacion(id_estacion, id_proyecto);
		name_site.text = estacion.nombre
		for _signal: Señal in estacion.signals.values():
			if _signal.tipo_signal == TIPO_SIGNAL.Tipo_Signal.Bomba:
				id_bomba = _signal.id_signal;
			if _signal.tipo_signal == TIPO_SIGNAL.Tipo_Signal.PerillaBomba:
				id_perilla = _signal.id_signal;
		_on_update_app()

func send_command():
	lbl_ejecutando.text = "EJECUTANDO\r\nEL COMANDO";
	data_to_send.Codigo = armar_codigo();
	data_to_send.idEstacion = id_estacion

	http_request.request(uri_reportes + str(id_proyecto), HEADERS, HTTPClient.METHOD_POST, JSON.stringify(data_to_send))

func armar_codigo() -> int:
	return ((id_estacion << 8) | (bomba.ordinal << 4) | ( 1 if arrancar else 2));

func _on_http_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	if _result == http_request.RESULT_SUCCESS:
		lbl_ejecutando.text = "COMANDO\r\nEJECUTADO"

	ejecutar = false
	tr_ejecutar.texture.set("region", boton_ejecucion[ejecutar])
	
var show = true;
	
func anim_ejecutar():
	
	print("anim_ejecutar: ", show)
	
	if show:
		ejecutar_background.visible = true;
		get_tween().tween_property(ejecutar_background, "scale", Vector2(0.1, 1), 1.0)
		await get_tween().tween_property(ejecutar_background, "scale", Vector2(1, 1), 1.0).finished
		ejecutar_background.material.set_shader_parameter("speed", 5);
		
		color_rect_background.visible = true;
		get_tween().tween_property(color_rect_loading.material, "shader_parameter/fill_amount", 1.0, 1.0)
		show = false
		
		start_writing();
		
	else:
		color_rect_background.visible = false;
		color_rect_loading.material.set_shader_parameter("fill_amount", 0.0);
		
		ejecutar_background.material.set_shader_parameter("speed", 0);
		get_tween().tween_property(ejecutar_background, "scale", Vector2(0.1, 1), 1.0)
		await get_tween().tween_property(ejecutar_background, "scale", Vector2(0.1, 0.1), 1.0).finished
		ejecutar_background.visible = false;
		show = true
	
func get_tween()->Tween:
	var tween = create_tween().set_parallel(true) 
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	return tween;

func _process(delta):
	if is_writing:
		matrix_timer += delta
		
		# Escribir nuevo carácter con delay
		if current_index < text_to_display.length() and matrix_timer >= character_delay:
			current_index += 1
			matrix_timer = 0.0
			current_text = text_to_display.substr(0, current_index)
		
		# Efecto Matrix para los caracteres que aún no son definitivos
		if current_index < text_to_display.length():
			var matrix_part = generate_matrix_text(text_to_display.length() - current_index)
			display_text = current_text + matrix_part
		else:
			# Cuando termina la escritura, mostrar texto final
			display_text = current_text
			is_writing = false
		
		label.text = display_text
		
@export var text_to_display: String = "ENVIANDO COMANDO"
@export var character_delay: float = 0.085  # Delay entre caracteres
@export var matrix_change_speed: float = 0.02  # Velocidad del cambio de caracteres Matrix
@export var matrix_characters: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%&*+-/="

var current_text: String = ""
var current_index: int = 0
var is_writing: bool = false
var matrix_timer: float = 0.0
var display_text: String = ""

func start_writing():
	current_text = ""
	current_index = 0
	is_writing = true
	display_text = ""
	matrix_timer = 0.0
	
func generate_matrix_text(length: int) -> String:
	var result = ""
	for i in range(length):
		var random_index = randi() % matrix_characters.length()
		result += matrix_characters[random_index]
	return result

func set_new_text(new_text: String):
	text_to_display = new_text
	start_writing()
