extends Node

@onready var niveles_container = %NivelesContainer

var transition_time: float = 0.75;
var id_estacion: int = 0;
var estacion: Estacion;
var id_signal_nivel: int = 0;
var id_signal_bateria: int = 0;
var ui_infos: Array[Node];

@onready var tr_enlace: TextureRect = %tr_enlace
@onready var lbl_id: Label = %lbl_id
@onready var lbl_interceptor: Label = %lbl_interceptor
@onready var lbl_nombre: Label = %lbl_nombre
@onready var lbl_fecha: Label = %lbl_fecha

func _ready() -> void:
	ui_infos = niveles_container.get_children()
	GlobalSignals.connect_on_update_app(update, true)
	update()

func _exit_tree() -> void:
	GlobalSignals.connect_on_update_app(update, false)

func init_data_info(_id_estacion: int) -> void:
	
	for child in ui_infos:
		child.visible = false;
	
	id_estacion = _id_estacion;
	estacion = GlobalData.get_estacion(id_estacion);
	
	var n = 0;

	for _signal: Señal in estacion.signals.values():
		if _signal.tipo_signal == TIPO_SIGNAL.Tipo_Signal.Nivel:
			ui_infos[n].visible = true;
			ui_infos[n].set_data_nivel(_signal)
			n += 0;
			
	update()

func update():
	if id_estacion != 0:
		estacion = GlobalData.get_estacion(id_estacion);
		tr_enlace.modulate = estacion.get_color_enlace();
		lbl_id.text = str(estacion.id_estacion)
		lbl_interceptor.text = estacion.abreviacion_interceptor
		lbl_nombre.text = estacion.nombre
		lbl_fecha.text = GlobalUtils.formatear_fecha(estacion.tiempo)
