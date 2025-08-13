extends Camera3D

func _ready() -> void:
	GlobalSignals.on_go_to_poi.emit(TIPO_POI.ENUM_POI.EXTERIOR1);
