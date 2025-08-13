extends Control

@onready var id: Label = %ID
@onready var name_site: Label = %Name_site
@onready var date: Label = %Date
@onready var pressure = %Pressure

var estacion: Estacion
var id_Estacion: int
var id_Proyecto: int
var id_Pressure: int

func inicializar_row(_estacion: Estacion):
	estacion = _estacion
	id_Estacion = estacion.id_estacion
	id_Proyecto = estacion.id_proyecto
	for _signal: Señal in estacion.signals.values():
		if _signal.tipo_signal == TIPO_SIGNAL.Tipo_Signal.Presion:
			id_Pressure = _signal.id_signal

func _ready():
	id.text = str(estacion.id_estacion)
	name_site.text = estacion.nombre
	GlobalSignals.connect_on_update_app(_on_update_app, true)
	_on_update_app()

func _on_update_app() -> void:
	estacion = GlobalData.get_estacion(id_Estacion, id_Proyecto)
	pressure.text = str(estacion.signals.get(id_Pressure).valor)
	date.text = GlobalUtils.formatear_fecha(estacion.tiempo)
