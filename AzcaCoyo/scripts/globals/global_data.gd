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
		if estacionesDict.get(estacion.id_proyecto) == null:
			estacionesDict[estacion.id_proyecto] = {}
		estacionesDict[estacion.id_proyecto][estacion.id_estacion] = estacion
	on_datos_actualizados.emit(get_all_data())

func parse_station_data(data) -> Estacion:
	var estacion = Estacion.new(data) #Se genera en el constructor
	for signal_data in data["signals"]:
		var señal = Señal.new(signal_data)
		
		#if signal_data.has("semaforo") and signal_data["semaforo"] != null:
			#var semaforo = Semaforo.new(signal_data["semaforo"])
			#señal.semaforo = semaforo
		
		estacion.signals[señal.id_signal] = señal
		
	return estacion

func get_estacion(id_estacion:int, id_proyecto:int ) -> Estacion:
	return estacionesDict[id_proyecto][id_estacion];

func get_all_data() -> Array:
	#return estacionesDict.values()
	var estaciones = []
	for sub_dict in estacionesDict.values():
		estaciones.append_array(sub_dict.values())
	return estaciones;
	
#endregion

func get_name_interceptor(id_proyecto: int) -> String:
	var name_id_proyecto: String = "Default"
	match id_proyecto:
		22:
			name_id_proyecto = "Coyoacán"
		23:
			name_id_proyecto = "Azcapotzalco"
	return name_id_proyecto

func get_color_interceptor(id_proyecto: int) -> Color:
	var color = Color("#FFFFFF")
	match id_proyecto:
		22:
			color = Color("5db665")
		23:
			color = Color("a871a3")
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
