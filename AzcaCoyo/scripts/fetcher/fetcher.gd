extends HTTPRequest

@export var uri_update : String 

var id_proyecto: int = 22;

#region Constantes
const INFRAESTRUCTURA = preload("res://scripts/offline_data/infraestructura.json")
#endregion

var intervalo_timer : float = 5.0 #En Segundos
var tiempo_acumulado : float = 0.0

#region Lyfecycle
func _ready() -> void:	
	_leer_Infraestructura()		
	set_process(true)
	_onUpdate()

func _process(delta: float) -> void:
	tiempo_acumulado += delta
	if tiempo_acumulado >= intervalo_timer:
		tiempo_acumulado = 0.0
		_onUpdate()
#endregion

#region VWC Functions
func _leer_Infraestructura() -> void : 
	GlobalData.set_data(INFRAESTRUCTURA.data)
#endregion

#region Signals Callbacks
func _onUpdate()-> void:
	request(uri_update + str(id_proyecto))
	
#Se connecta desde el editor en la parte de nodos
func _on_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result == RESULT_SUCCESS:
		GlobalData.total_online = 0
		var data = JSON.parse_string(body.get_string_from_utf8())
		if data:
			for data_estacion in data.E.keys():
				var estacion = GlobalData.get_estacion(int(data_estacion), id_proyecto)
				estacion.update_estacion(data.E[data_estacion])
				GlobalData.total_online += 1 if estacion.is_estacion_en_linea() else 0
			GlobalData.total_offline = data.E.size() -GlobalData.total_online
		GlobalSignals.on_update_app.emit()
	else:
		print("Servicio no alcanzado")
		
	id_proyecto = 23 if id_proyecto == 22 else 22
		
#endregion
