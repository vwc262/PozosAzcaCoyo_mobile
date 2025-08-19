extends Control

@onready var id: Label = %ID
@onready var name_site: Label = %Name_site
@onready var date: Label = %Date
@onready var pressure = %Pressure
@onready var in_line = %inLine

var estacion: Estacion
var id_Estacion: int
var id_Proyecto: int
var id_Pressure: int

const alarmado_coor := {
	false: Rect2(159, 190, 50, 50),  # rojo
	true: Rect2(213, 190, 50, 50),  # verde
	#2: Rect2(213, 190, 50, 50),  # verde
	#3: Rect2(213, 190, 50, 50),  # verde
}

func _ready():
	id.text = str(estacion.id_estacion)
	name_site.text = estacion.nombre
	GlobalSignals.connect_on_update_app(_on_update_app, true)
	_on_update_app()

func inicializar_row(_estacion: Estacion):
	estacion = _estacion
	id_Estacion = estacion.id_estacion
	id_Proyecto = estacion.id_proyecto
	for _signal: Señal in estacion.signals.values():
		if _signal.tipo_signal == TIPO_SIGNAL.Tipo_Signal.Presion:
			id_Pressure = _signal.id_signal

func _on_update_app() -> void:
	estacion = GlobalData.get_estacion(id_Estacion, id_Proyecto)
	pressure.text = str(estacion.signals.get(id_Pressure).get_valor_string())
	date.text = GlobalUtils.formatear_fecha(estacion.tiempo)
	in_line.texture.set('region', alarmado_coor[estacion.is_estacion_en_linea()])


func _on_button_pressed():
	GlobalSignals.on_site_row_clicked.emit(id_Proyecto, id_Estacion)
