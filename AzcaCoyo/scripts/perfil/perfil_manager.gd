extends Node3D

@onready var pois_alcaldias: Node3D = $pois_alcaldias
@onready var mesh_mapa: Node3D = $MeshMapa
@onready var multi_mesh_instance_3d_coyoacan: MultiMeshInstance3D = %MultiMeshInstance3D_coyoacan
@onready var posiciones_coyo_azc: Node3D = %posiciones_coyoAzc


const BOMBA_AZCACOYO_01 = preload("res://assets/models/Perfil/iconos/Bomba_Azcacoyo_01.glb")

func _ready() -> void:
	for poi in pois_alcaldias.get_children():
		GlobalSignals.on_agregar_poi_perfil.emit(0, int(poi.name.split('_')[2]), poi.transform)

	var anim_player: AnimationPlayer = mesh_mapa.get_node("Aeropuerto/AnimationPlayer")
	anim_player.play("Avion_Vuelo_001")  # Nombre exacto de la animación
		
	multi_mesh_instance_3d_coyoacan.multimesh.instance_count = 0;
	multi_mesh_instance_3d_coyoacan.multimesh.use_colors = true;
	multi_mesh_instance_3d_coyoacan.multimesh.transform_format = MultiMesh.TRANSFORM_3D;
	
	var instanced_mesh: Mesh = BOMBA_AZCACOYO_01.instantiate().get_child(0).mesh;
	
	var i = 0;
	var base_transform = Transform3D.IDENTITY;
	var meshes = posiciones_coyo_azc.get_children();
	
	multi_mesh_instance_3d_coyoacan.multimesh.instance_count = meshes.size();
	multi_mesh_instance_3d_coyoacan.multimesh.mesh = instanced_mesh;
	
	for child in meshes:
		if child is MeshInstance3D:
			if child.name.contains('_'):
				var id_proyecto = int(child.name.split("_")[1]);
				var id_estacion = int(child.name.split("_")[2]);
								
				child.queue_free();
				base_transform = Transform3D.IDENTITY;
				base_transform.origin = child.position
				multi_mesh_instance_3d_coyoacan.multimesh.set_instance_transform(i, base_transform)
				i += 1;
