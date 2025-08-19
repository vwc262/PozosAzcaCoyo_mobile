extends Control

@onready var lbl_titulo: Label = $Panel3/VBoxContainer/PanelContainer/lbl_titulo
@onready var graph_2d: Graph2D = %Graph2D
@onready var sin_historicos = %SinHistoricos
@onready var http_request = %HTTPRequest

#region Datos API Reportes
var data_to_send: Dictionary = {
	"idSignal": 175,
	"FechaInicial": "2025-07-08 00:00",
	"FechaFinal": "2025-07-08 23:59"
}

const HEADERS = ["Content-Type: application/json"]
#const uri_reportes: String = "https://virtualwavecontrol.com.mx/api24/VWC/APP2024/GetReportes/?idProyecto=25"
var uri_reportes: String

var estacion: Estacion;
var signals: Array[Señal];
var diccionario_historicos = {}
var line_indexes: Array[int]

var line_n1 = LineSeries.new(GlobalData.get_color_signal(0), 2.0)
var line_n2 = LineSeries.new(GlobalData.get_color_signal(1), 2.0)
var line_n3 = LineSeries.new(GlobalData.get_color_signal(2), 2.0)
var line_n4 = LineSeries.new(GlobalData.get_color_signal(3), 2.0)

var conHistoricos: bool = false

var sql_time: String = ""
var sql_time_ayer: String = ""
var _ahora: Dictionary = {}
var _ayer: Dictionary = {}

var y_max: float = 10

var indice: int = 0

func _ready():
	GlobalSignals.connect_on_site_row_clicked(_onsiteclic, true)

func _onsiteclic(_id_proyecto: int, _id_estacion: int): 
	estacion = GlobalData.get_estacion(_id_estacion, _id_proyecto)
	signals = []
	var id_proyecto = estacion.id_proyecto
	
	for _signal: Señal in estacion.signals.values():
		if _signal.tipo_signal == TIPO_SIGNAL.Tipo_Signal.Presion || _signal.tipo_signal == TIPO_SIGNAL.Tipo_Signal.Gasto:
			signals.append(_signal);
	
	init_graficador(id_proyecto, estacion, signals)

func init_graficador(_idProyecto:int, _estacion: Estacion, _signals: Array[Señal]):
	uri_reportes = "https://virtualwavecontrol.com.mx/api24/VWC/APP2024/GetReportes/?idProyecto=" + str(_idProyecto)

	_ahora = Time.get_datetime_dict_from_system()
	var ayer_unix = Time.get_unix_time_from_datetime_dict(_ahora) - (24 * 60 * 60)  # Restar 86400 segundos (1 día)
	_ayer = Time.get_datetime_dict_from_unix_time(ayer_unix)
	sql_time = GlobalUtils.formatear_fecha_sql(_ahora)
	sql_time_ayer = GlobalUtils.formatear_fecha_sql(_ayer)

	graph_2d.x_min = -_ahora["hour"]
	graph_2d.x_max = _ahora["hour"]

	lbl_titulo.text = "{0}".format([_estacion.nombre])
	estacion = _estacion;
	signals = _signals;

	limpiar_graph()
	iniciar_series(signals[indice])

func limpiar_graph() -> void:
	line_indexes = []
	indice = 0
	y_max = 0
	conHistoricos = false
	graph_2d.clear_data()
	line_n1.clear_data()
	line_n2.clear_data()
	line_n3.clear_data()
	line_n4.clear_data()

func _on_datos_24h_recibidos(result, _response_code, _headers, body):
	if result == http_request.RESULT_SUCCESS:
		var response = JSON.parse_string(body.get_string_from_utf8())
		if response and response.has("Reporte"):
			var reportes: Array = response["Reporte"]
			if reportes.size() > 0:
				print("con historicos")
				process_data(reportes)
				conHistoricos = true

	indice += 1
	if indice < signals.size():
		print("faltan mas signlas por graficar ", indice)
		iniciar_series(signals[indice])
	else:
		graph_2d.visible = conHistoricos
		sin_historicos.visible = !conHistoricos

func fetch_data(nivel: Señal) -> void:
	data_to_send.idSignal = nivel.id_signal
	data_to_send.FechaInicial = sql_time_ayer
	data_to_send.FechaFinal = sql_time

	http_request.request(uri_reportes, HEADERS, HTTPClient.METHOD_POST, JSON.stringify(data_to_send))

func process_data(reportes: Array) -> void:
	var _reportes = {}
	var idSignal: int = int(reportes[0].IdSignal)
	var ordinal = line_indexes.find(idSignal)
	var line: LineSeries = (line_n1 
	if ordinal == 0 else line_n2 
	if ordinal == 1 else line_n3
	if ordinal == 2 else line_n4)

	#for dato: Reporte in reportes as Array[Reporte]:
		#var tiempo = Time.get_datetime_dict_from_datetime_string(dato.Tiempo, false)
		#var valor = float(dato.Valor)
		#line.add_point(tiempo["hour"] if tiempo["day"] >= _ahora["day"] else -tiempo["hour"], valor)
		#if valor > y_max:
			#y_max = valor

	var promedios_por_hora = {}
	for dato: Reporte in reportes as Array[Reporte]:
		var tiempo = Time.get_datetime_dict_from_datetime_string(dato.Tiempo, false)
		var valor = float(dato.Valor)

		var hora = tiempo["hour"]
		var dia = tiempo["day"]

		# Crear clave única que incluya hora y día
		var clave = str(dia) + "_" + str(hora)

		if not promedios_por_hora.has(clave):
			promedios_por_hora[clave] = {
				"suma": 0.0,
				"contador": 0,
				"hora": hora,
				"dia": dia
			}

		promedios_por_hora[clave]["suma"] += valor
		promedios_por_hora[clave]["contador"] += 1

		if valor > y_max:
			y_max = valor

	# Agregar puntos promediados
	for clave in promedios_por_hora:
		var datos = promedios_por_hora[clave]
		var promedio = datos["suma"] / datos["contador"]
		var pos_x = datos["hora"] if datos["dia"] >= _ahora["day"] else -datos["hora"]
		line.add_point(pos_x, promedio)

	graph_2d.y_max = y_max * 1.1

func iniciar_series(nivel: Señal) -> void:
	var line: LineSeries = (line_n1 
	if indice == 0 else line_n2)
	graph_2d.add_series(line)
	line_indexes.append(nivel.id_signal)
	fetch_data(nivel)
