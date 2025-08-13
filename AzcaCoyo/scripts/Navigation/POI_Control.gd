extends Node3D
class_name POI_Cam

@export_category("Configuracion")
@export var habilitado:bool;
@export var tipo: TIPO_POI.ENUM_POI;

func _ready() -> void:
	if habilitado:
		GlobalSignals.on_agregar_poi_particular.emit(tipo, global_transform)
