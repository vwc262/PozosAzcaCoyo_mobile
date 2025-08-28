extends Node

@onready var http_request: HTTPRequest = %HTTPRequest
@onready var name_site = %name_site
@onready var tr_bomba: TextureRect = %tr_bomba
@onready var lbl_accion: Label = %lbl_accion
@onready var lbl_perilla_bomba: Label = %lbl_perilla_bomba
@onready var lbl_edo_bomba: Label = %lbl_edo_bomba
@onready var tr_accion: TextureRect = %tr_accion
@onready var tr_ejecutar: TextureRect = %tr_ejecutar
@onready var ejecutar_background: TextureRect = %ejecutar_background
@onready var color_rect_background: ColorRect = %ColorRect_background
@onready var color_rect_loading: ColorRect = %ColorRect_loading
@onready var label: Label = %Label

@onready var bomba_container = %BombaContainer
@onready var button_ejecutar = %Button_ejecutar
@onready var button_accion = %Button_accion
@onready var apagar_text_container = %ApagarTextContainer

var id_estacion: int = 0;
var id_proyecto: int = 0;
var id_bomba: int = 0;
var id_perilla: int = 0;
var arrancar: bool = false;
var ejecutar: bool = false;
var estacion: Estacion;
var bomba: Señal;
var perilla: Señal;

const GRADIENT_TEXTURE_ON_OFF_UI_2D = preload("res://assets/textures/FX/gradient_texture_onOff_UI2D.tres")
const GRADIENT_TEXTURE_OFF_ON_UI_2D = preload("res://assets/textures/FX/gradient_texture_offOn_UI2D.tres")

var tween_actual: Tween

const boton_accion := {
	true: Rect2(760, 2065, 179, 182),
	false: Rect2(760, 2265, 179, 182),
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
	showButtos(0)
	
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
		lbl_edo_bomba.text = "ENCENDIDA" if bomba.valor == 1 else "APAGADA" if perilla.valor == 2 else "EN FALLA" if perilla.valor == 3 else "NO DISPONIBLE"
		lbl_edo_bomba.add_theme_color_override("font_color", Color.GREEN if bomba.valor == 1 else Color.RED if perilla.valor == 2 else Color.BLUE if perilla.valor == 3 else Color.DIM_GRAY)

func _on_button_accion_pressed() -> void:
	arrancar = !arrancar
	tr_accion.texture.set("region", boton_accion[arrancar])

	ejecutar = false
	tr_ejecutar.visible = true;

	lbl_accion.text = "ENCENDER" if arrancar else "APAGAR"
	lbl_accion.label_settings.font_color = Color.GREEN if arrancar else Color.RED
	show = true;
	ejecutar_background.visible = false;
	color_rect_background.visible = false;
	
func _on_button_ejecutar_pressed() -> void:
	ejecutar = !ejecutar
	tr_ejecutar.visible = false;

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
	anim_ejecutar("COMANDO ENVIADO");
	data_to_send.Codigo = armar_codigo();
	data_to_send.idEstacion = id_estacion

	http_request.request(uri_reportes + str(id_proyecto), HEADERS, HTTPClient.METHOD_POST, JSON.stringify(data_to_send))

func armar_codigo() -> int:
	return ((id_estacion << 8) | (bomba.ordinal << 4) | ( 1 if arrancar else 2));

func _on_http_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	if _result == http_request.RESULT_SUCCESS:
		anim_ejecutar("COMANDO EJECUTADO");

	ejecutar = false
	
var show = true;
	
func anim_ejecutar(text: String):
	text_to_display = text;
	
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
			
			#tr_ejecutar.visible = true;
		
		label.text = display_text
		
var text_to_display: String = "ENVIANDO COMANDO"
var character_delay: float = 0.085  # Delay entre caracteres
var matrix_change_speed: float = 0.02  # Velocidad del cambio de caracteres Matrix
var matrix_characters: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%&*+-/="

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

func showButtos(alpha: float):
	if tween_actual and tween_actual.is_running():
		tween_actual.kill()

	tween_actual = create_tween()
	tween_actual.set_ease(Tween.EASE_IN_OUT)
	tween_actual.set_trans(Tween.TRANS_SINE)
	tween_actual.parallel().tween_property(bomba_container, "modulate:a", alpha, 0.5)
	tween_actual.tween_interval(1)
	tween_actual.parallel().tween_property(button_accion, "modulate:a", alpha, 0.5)
	tween_actual.tween_interval(0.2)
	tween_actual.parallel().tween_property(apagar_text_container, "modulate:a", alpha, 0.5)
	tween_actual.tween_interval(0.3)
	tween_actual.parallel().tween_property(button_ejecutar, "modulate:a", alpha, 0.5)

	await tween_actual.finished
	tween_actual.kill()
	tween_actual = null
