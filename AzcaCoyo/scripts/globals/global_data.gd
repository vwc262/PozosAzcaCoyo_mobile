extends Node
class_name DatosGlobales

#region Signals
signal on_datos_actualizados
#endregion

#region Variables
var estacionesDict = {}
var total_online : int = 0
var total_offline : int = 0
var selected_particular: int = 0;
#endregion

#region navigation
var min_zoom: float = 0.0
var max_zoom: float = 0.0
#endregion

#region funciones propias
func set_data(json_infraestructura):
	for data in json_infraestructura:
		var estacion = parse_station_data(data)
		estacionesDict[estacion.id_estacion] = estacion
	on_datos_actualizados.emit(get_all_data())		

func parse_station_data(data) -> Estacion:
	var estacion = Estacion.new(data) #Se genera en el constructor
	for signal_data in data["signals"]:
		var señal = Señal.new(signal_data)
		
		if signal_data.has("semaforo") and signal_data["semaforo"] != null:
			var semaforo = Semaforo.new(signal_data["semaforo"])
			señal.semaforo = semaforo
		
		estacion.signals[señal.id_signal] = señal
		
		#if señal.tipo_signal == 11:
			#estacion.set_tipo_poleo(señal.id_signal)
	
	for linea_data in data["lineas"]:
		var linea = Linea.new(linea_data)
		estacion.lineas.append(linea)
	return estacion

func get_estacion(id_estacion:int) -> Estacion:
	return estacionesDict[id_estacion]

func get_all_data() -> Array:
	return estacionesDict.values()
#endregion

func get_name_interceptor(interceptor: int) -> String:
	var name_interceptor: String = "Default"
	match interceptor:
		1:
			name_interceptor = "Emisor Central"
		2:
			name_interceptor = "Interceptor Centro - Poniente"
		3:
			name_interceptor = "Interceptor Poniente"
		4:
			name_interceptor = "Interceptor Central"
		5:
			name_interceptor = "Interceptor Oriente"
		6:
			name_interceptor = "Interceptor Oriente - Sur"
		7:
			name_interceptor = "Gran Canal"
		8:
			name_interceptor = "Río Hondo"
		9:
			name_interceptor = "Canal de Miramontes"
		10:
			name_interceptor = "Canal Nacional - Canal Chalco"
		11:
			name_interceptor = "Interceptor Oriente - Oriente"
		12:
			name_interceptor = "Viaducto Río de la Piedad"
		13:
			name_interceptor = "Río Magdalena"
		14:
			name_interceptor = "Tunel Emisor Oriente"
		15:
			name_interceptor = "Rio Consulado"
		16:
			name_interceptor = "Interceptor Centro Centro"
		17:
			name_interceptor = "Iztapalapa"
		18:
			name_interceptor = "Río Churubusco"
	return name_interceptor

func get_color_interceptor(interceptor: int) -> Color:
	var color = Color("#FFFFFF")
	match interceptor:
		1:
			color = Color("5db665")
		2:
			color = Color("a871a3")
		3:
			color = Color("c564d3")
		4:
			color = Color("59cdbd")
		5:
			color = Color("d850a0")
		6:
			color = Color("a1c667")
		7:
			color = Color("9daabd")
		8:
			color = Color("8bcefb")
		9:
			color = Color("92adce")
		10:
			color = Color("d6e8ed")
		11:
			color = Color("34a32b")
		12:
			color = Color("cd842b")
		13:
			color = Color("a4b2bc")
		14:
			color = Color("f3ffeb")
		15:
			color = Color("d9de90")
		16:
			color = Color("9ccf59")
		17:
			color = Color("3e381e")
		18:
			color = Color("87695e")
	return color

func get_total_online(estaciones: Array) -> int:
	var online = 0
	for estacion in estaciones:
		if estacion.is_estacion_en_linea():
			online += 1
	return online

func get_color_signal(ordinal: int) -> Color:
	var color = Color("#FFFFFF")
	match ordinal:
		0:
			color = Color("13d4c7")
		1:
			color = Color("ff8000")
		2:
			color = Color("27b621")
		3:
			color = Color("f5228e")
	return color

func get_estado_alarmado(estacion: Estacion) -> TIPO_ALERTA.ENUM_ALERTA:
	var tipo_alerta = TIPO_ALERTA.ENUM_ALERTA.NORMAL
	for nivel: Señal in estacion.signals.values():
		if nivel.tipo_signal == 1 && (nivel.valor > 0 && nivel.valor < 9999):
			var preventivo = nivel.semaforo.preventivo if nivel.semaforo else 6.0
			var critico = nivel.semaforo.critico if nivel.semaforo else 5.0
			var valor = nivel.valor
			if valor >= critico:
				tipo_alerta = TIPO_ALERTA.ENUM_ALERTA.CRITICO
				break
			elif valor >= preventivo:
				tipo_alerta = TIPO_ALERTA.ENUM_ALERTA.PREVENTIVO
	return tipo_alerta
	
func get_color_estdado_alertado(estacion: Estacion) -> Color:
	var alerta: TIPO_ALERTA.ENUM_ALERTA = GlobalData.get_estado_alarmado(estacion);
	return Color(0, .7, 0) if alerta == TIPO_ALERTA.ENUM_ALERTA.NORMAL else Color(.7, .7, 0) if alerta == TIPO_ALERTA.ENUM_ALERTA.PREVENTIVO else Color(.7, 0, 0)
