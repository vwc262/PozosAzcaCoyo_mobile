extends Node

@onready var http_request: HTTPRequest = %HTTPRequest
@onready var tr_bomba: TextureRect = %tr_bomba
@onready var lbl_ejecutando: Label = %lbl_ejecutando
@onready var lbl_perilla_bomba: Label = %lbl_perilla_bomba
@onready var tr_accion: TextureRect = %tr_accion
@onready var tr_ejecutar: TextureRect = %tr_ejecutar

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
	GlobalSignals.connect_on_site_row_clicked(_on_site_row_clicked, true)
	GlobalSignals.connect_on_update_app(_on_update_app, true);
	
func _exit_tree() -> void:
	GlobalSignals.connect_on_site_row_clicked(_on_site_row_clicked, false)
	GlobalSignals.connect_on_update_app(_on_update_app, false);
	
func _on_update_app() -> void:
	if  id_bomba != 0:
		estacion = GlobalData.get_estacion(id_estacion, id_proyecto);
		bomba = estacion.signals.get(id_bomba);
		perilla = estacion.signals.get(id_perilla);
		
		tr_bomba.modulate = bomba.get_color_bomba_string();
		lbl_perilla_bomba.text = "REM" if perilla.valor == 1 else "LOC" if perilla.valor == 2 else "OFF"

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

func _on_site_row_clicked(_id_proyecto: int, _id_estacion: int):
	id_estacion = _id_estacion
	id_proyecto = _id_proyecto
	
	estacion = GlobalData.get_estacion(id_estacion, id_proyecto);
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

func _on_http_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if _result == http_request.RESULT_SUCCESS:
		lbl_ejecutando.text = "COMANDO\r\nEJECUTADO"
	
	ejecutar = false
	tr_ejecutar.texture.set("region", boton_ejecucion[ejecutar])
