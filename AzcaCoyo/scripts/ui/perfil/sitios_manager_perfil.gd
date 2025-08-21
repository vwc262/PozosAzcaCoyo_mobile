extends Node

var PREFAB = preload("res://assets/Prefab/MarcadorSitio.tscn")

func _ready(): pass
	#for child in get_children():
		#if child is MeshInstance3D:
			#if child.name.contains('_'):
				#var id_proyecto = int(child.name.split("_")[1]);
				#var id_estacion = int(child.name.split("_")[2]);
#
				#var instanced_scene = PREFAB.instantiate()
				#instanced_scene.position = child.position;
				#instanced_scene.scale = Vector3.ONE * 0.145;
					#
				#instanced_scene.initialize(id_estacion, id_proyecto)
					#
				#self.add_child(instanced_scene);
				#
			#child.queue_free();
