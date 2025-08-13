extends Node

var id_estacion: int = 0;

func _ready() -> void:
	id_estacion = GlobalData.selected_particular;
	GlobalSignals.on_particular_loaded.emit(id_estacion);	
	get_viewport().disable_3d = false
