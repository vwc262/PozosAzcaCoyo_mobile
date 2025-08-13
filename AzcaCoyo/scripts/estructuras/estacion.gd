extends RefCounted
class_name Estacion
@export var id_estacion: int
@export var nombre: String
@export var latitud: float
@export var longitud: float
@export var tiempo: String
@export var enlace: int
@export var falla_energia: int
@export var abreviacion: String
@export var tipo_estacion: int
@export var signals = {}
var lineas: Array[Linea] = []
@export var conexiones: int
@export var fallas: int
@export var tipo_poleo: int
@export var abreviacion_interceptor: String
@export var tipo_interceptor: int
@export var interceptor: String

const tolerancia_minutos : int = 15

#Constructor Estacion
func _init(jsonData):
	self.id_estacion = jsonData["idEstacion"]
	self.nombre = jsonData["nombre"]
	self.latitud = jsonData["latitud"]
	self.longitud = jsonData["longitud"]
	self.tiempo = jsonData["tiempo"]
	self.enlace = jsonData["enlace"]
	self.falla_energia = jsonData["fallaEnergia"]
	self.abreviacion = jsonData["abreviacion"]
	self.tipo_estacion = jsonData["tipoEstacion"]
	self.conexiones = jsonData["conexiones"]
	self.fallas = jsonData["fallas"]
	self.abreviacion_interceptor = jsonData["abreviacion_interceptor"]
	self.tipo_interceptor = jsonData["tipo_interceptor"]
	self.interceptor = jsonData["interceptor"]

func is_tiempo_NoValido()->bool:
	var current_time = Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system(false))
	var estacion_time  = Time.get_unix_time_from_datetime_string(tiempo)
	var difference_minutes = (current_time - estacion_time) / 60.0	
	return difference_minutes > tolerancia_minutos

func is_estacion_en_linea() -> bool:	
	var isTiempoNoValido = self.is_tiempo_NoValido()
	if(isTiempoNoValido):
		return false
	var result = self.enlace
	return  enlace in [1, 2, 3] if result != 0 else false

func get_color_enlace():
	return Color.from_string("#00ff00", "green") if is_estacion_en_linea() else Color.from_string("#ff4838", "red")

func update_estacion(jsonDataUpdate) -> Estacion:
	self.enlace = jsonDataUpdate.E
	self.tiempo =  jsonDataUpdate.T	
	self.falla_energia = jsonDataUpdate.F	
	for signalId_update in jsonDataUpdate.S.keys():			
		self.signals[int(signalId_update)].update_signal(jsonDataUpdate.S[signalId_update])		
	return self	

func get_all_signals_by_type(tipo_signal: TIPO_SIGNAL.Tipo_Signal) -> Array[Señal]:
	var keys = self.signals.keys();
	var array_aux: Array[Señal] = [];
	
	for k in keys:
		if (self.signals[k].tipo_signal == int(tipo_signal)):
			array_aux.push_back(self.signals[k]);
	
	return array_aux;
	
func get_signal_by_type_and_ordinal(tipo_signal: TIPO_SIGNAL.Tipo_Signal, ordinal: int) -> Señal:
	var keys = self.signals.keys();
	var signal_aux: Señal;
	
	for k in keys:
		if (self.signals[k].tipo_signal == int(tipo_signal) && self.signals[k].ordinal == ordinal):
			signal_aux = self.signals[k];
	
	return signal_aux;
