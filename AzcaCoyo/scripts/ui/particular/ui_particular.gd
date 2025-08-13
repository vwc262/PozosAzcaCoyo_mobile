extends Control

@onready var ui_info_sitio: Control = %UiInfoSitio

var id_estacion: int;

func _ready() -> void:
	GlobalSignals.connect_on_particular_loaded(_on_particular_loaded, true)
	
func _exit_tree() -> void:
	GlobalSignals.connect_on_particular_loaded(_on_particular_loaded, false)
	
func _on_particular_loaded(_id_estacion: int):
	id_estacion = _id_estacion
	
	ui_info_sitio.init_data_info(id_estacion);
