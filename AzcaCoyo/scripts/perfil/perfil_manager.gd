extends Node3D

@onready var pois_alcaldias: Node3D = $pois_alcaldias


func _ready() -> void:
	for poi in pois_alcaldias.get_children():
		GlobalSignals.on_agregar_poi_perfil.emit(-int(poi.name.split('_')[2]), global_transform)
