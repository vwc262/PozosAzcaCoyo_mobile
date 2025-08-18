extends Node3D

@onready var pois_alcaldias: Node3D = $pois_alcaldias
@onready var mesh_mapa: Node3D = $MeshMapa

func _ready() -> void:
	for poi in pois_alcaldias.get_children():
		GlobalSignals.on_agregar_poi_perfil.emit(0, int(poi.name.split('_')[2]), poi.transform)

	var anim_player: AnimationPlayer = mesh_mapa.get_node("Aeropuerto/AnimationPlayer")
	anim_player.play("Avion_Vuelo_001")  # Nombre exacto de la animación
