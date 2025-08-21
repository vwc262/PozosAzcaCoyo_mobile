extends Node3D

@onready var pois_alcaldias: Node3D = $pois_alcaldias
@onready var mesh_mapa: Node3D = $MeshMapa
@onready var multi_mesh_instance_3d_bombas: MultiMeshInstance3D = %MultiMeshInstance3D_bombas
@onready var multi_mesh_instance_3d_esferas: MultiMeshInstance3D = %MultiMeshInstance3D_esferas
@onready var posiciones_coyo_azc: Node3D = %posiciones_coyoAzc

const BOMBA_AZCACOYO_01 = preload("res://assets/models/Perfil/iconos/Bomba_Azcacoyo_01.glb")
const ETIQUETA_PERFIL_3D = preload("res://assets/models/Props/Etiqueta_Perfil_3D.glb")

func _ready() -> void:
	for poi in pois_alcaldias.get_children():
		GlobalSignals.on_agregar_poi_perfil.emit(0, int(poi.name.split('_')[2]), poi.transform)

	var anim_player: AnimationPlayer = mesh_mapa.get_node("Aeropuerto/AnimationPlayer")
	anim_player.play("Avion_Vuelo_001")  # Nombre exacto de la animación
		
	multi_mesh_instance_3d_bombas.multimesh.instance_count = 0;
	multi_mesh_instance_3d_bombas.multimesh.use_colors = true;
	multi_mesh_instance_3d_bombas.multimesh.transform_format = MultiMesh.TRANSFORM_3D;
	
	multi_mesh_instance_3d_esferas.multimesh.instance_count = 0;
	multi_mesh_instance_3d_esferas.multimesh.use_colors = true;
	multi_mesh_instance_3d_esferas.multimesh.transform_format = MultiMesh.TRANSFORM_3D;
	
	var instanced_bomba: Mesh = BOMBA_AZCACOYO_01.instantiate().get_child(0).mesh;
	var instanced_sphere: Mesh = ETIQUETA_PERFIL_3D.instantiate().get_child(0).mesh;
	
	var i = 0;
	var base_transform = Transform3D.IDENTITY;
	var meshes = posiciones_coyo_azc.get_children();
	
	multi_mesh_instance_3d_bombas.multimesh.instance_count = meshes.size();
	multi_mesh_instance_3d_bombas.multimesh.mesh = instanced_bomba;
	
	multi_mesh_instance_3d_esferas.multimesh.instance_count = meshes.size();
	multi_mesh_instance_3d_esferas.multimesh.mesh = instanced_sphere;
	
	for child in meshes:
		if child is MeshInstance3D:
			if child.name.contains('_'):
				var id_proyecto = int(child.name.split("_")[1]);
				var id_estacion = int(child.name.split("_")[2]);
								
				child.queue_free();
				base_transform = Transform3D.IDENTITY;
				base_transform.origin = child.position
								
				var collision_shape : CollisionShape3D = CollisionShape3D.new()
				collision_shape.shape = ConcavePolygonShape3D.new()
				collision_shape.shape.set_faces(instanced_sphere.get_faces())
				
				var static_body : StaticBody3D = StaticBody3D.new()
				static_body.add_child(collision_shape)
				static_body.transform = base_transform
				multi_mesh_instance_3d_esferas.add_child(static_body)
				
				multi_mesh_instance_3d_bombas.multimesh.set_instance_transform(i, base_transform)
				multi_mesh_instance_3d_esferas.multimesh.set_instance_transform(i, base_transform)
				
				i += 1;
