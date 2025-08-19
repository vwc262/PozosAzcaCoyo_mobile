extends Node

@onready var tr_bomba: TextureRect = %tr_bomba
@onready var ejecutando: Label = %lbl_ejecutando
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

func initialize(_id_estacion: int, _id_proyecto: int, _id_bomba: int) -> void:
	_id_estacion = _id_estacion
	id_proyecto = _id_proyecto
	id_bomba = _id_bomba
	
	estacion = GlobalData.get_estacion(id_estacion, id_proyecto);
	for _signal: Señal in estacion.signals.values():
		if _signal.tipo_signal == TIPO_SIGNAL.Tipo_Signal.PerillaBomba:
			id_perilla = _signal.id_signal;
			break;
	
func _ready() -> void:
	
	GlobalSignals.connect_on_update_app(_on_update_app, true);
	
func _exit_tree() -> void:
	GlobalSignals.connect_on_update_app(_on_update_app, false);
	
func _on_update_app() -> void:
	if id_bomba != 0:
		estacion = GlobalData.get_estacion(id_estacion, id_proyecto);
		bomba = estacion.signals.get(id_bomba);
		perilla = estacion.signals.get(id_perilla);
		
		tr_bomba.modulate = bomba.get_color_bomba_string();
		lbl_perilla_bomba.text =  "REM" if perilla.valor == 1 else "LOC" if perilla.valor == 2 else "OFF"

func _on_button_accion_pressed() -> void:
	arrancar != arrancar
	
	tr_accion.texture.set("region", boton_accion[arrancar])


func _on_button_ejecutar_pressed() -> void:
	ejecutar != ejecutar
	
	tr_ejecutar.texture.set("region", boton_ejecucion[ejecutar])
