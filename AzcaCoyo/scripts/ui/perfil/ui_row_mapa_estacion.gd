extends Control

@onready var id: Label = %ID
@onready var name_site: Label = %Name_site
@onready var date: Label = %Date
@onready var pressure = %Pressure
@onready var in_line = %inLine

@onready var site_selected = %SiteSelected

var estacion: Estacion
var id_Estacion: int
var id_Proyecto: int
var id_Pressure: int

const alarmado_coor := {
	false: Rect2(159, 190, 50, 50),  # rojo
	true: Rect2(213, 190, 50, 50),  # verde
}

func _ready():
	id.text = str(estacion.id_estacion)
	name_site.text = estacion.nombre
	GlobalSignals.connect_on_update_app(_on_update_app, true)
	GlobalSignals.connect_on_site_row_clicked(_on_Site_Click, true)
	GlobalSignals.connect_on_mini_site_clicked(_reset, true)
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

func _on_Site_Click(_id_proyecto: int, _id_estacion: int):
	var select: bool = (_id_estacion == id_Estacion && _id_proyecto == id_Proyecto)
	site_selected.visible = select

func _reset(_id_estacion: int, _id_proyecto: int):
	site_selected.visible = _id_proyecto != 0 && _id_estacion == id_Estacion

func _on_button_pressed():
	GlobalSignals.on_site_row_clicked.emit(id_Proyecto, id_Estacion)
	GlobalSignals.on_mini_site_clicked.emit(id_Estacion, id_Proyecto)
