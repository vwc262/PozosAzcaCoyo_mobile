extends Node3D

@onready var pois_alcaldias: Node3D = $pois_alcaldias
@onready var mesh_mapa: Node3D = $MeshMapa
@onready var multi_mesh_instance_3d_bombas: MultiMeshInstance3D = %MultiMeshInstance3D_bombas
@onready var multi_mesh_instance_3d_esferas: MultiMeshInstance3D = %MultiMeshInstance3D_esferas
@onready var multi_mesh_instance_3d_labels: MultiMeshInstance3D = %MultiMeshInstance3D_labels

@onready var posiciones_coyo_azc: Node3D = %posiciones_coyoAzc

@export var material_bomba: Material;
@export var material_sphere: Material;
@export var material_label: Material;

var diccionario_sitios: Dictionary = {};
@onready var camera_3d_perfil: TouchCameraController = %Camera3D_Perfil

const BOMBA_AZCACOYO_01 = preload("res://assets/models/Perfil/iconos/Bomba_Azcacoyo_01.glb")
const ETIQUETA_PERFIL_3D = preload("res://assets/models/Props/Etiqueta_Perfil_3D.glb")

#region input
const UMBRAL_SINGLE_CLICK := 0.25
var tiempo_click: float = 0.0
#endregion

func _ready() -> void:
	
	for poi in pois_alcaldias.get_children():
		GlobalSignals.on_agregar_poi_perfil.emit(0, int(poi.name.split('_')[2]), poi.transform)
		poi.queue_free();

	var anim_player: AnimationPlayer = mesh_mapa.get_node("Aeropuerto/AnimationPlayer")
	anim_player.play("Avion_Vuelo_001")  # Nombre exacto de la animación
		
	multi_mesh_instance_3d_bombas.multimesh.instance_count = 0;
	multi_mesh_instance_3d_bombas.multimesh.use_colors = true;
	multi_mesh_instance_3d_bombas.multimesh.use_custom_data = true;
	multi_mesh_instance_3d_bombas.multimesh.transform_format = MultiMesh.TRANSFORM_3D;
	
	multi_mesh_instance_3d_esferas.multimesh.instance_count = 0;
	multi_mesh_instance_3d_esferas.multimesh.use_colors = true;
	multi_mesh_instance_3d_esferas.multimesh.use_custom_data = true;
	multi_mesh_instance_3d_esferas.multimesh.transform_format = MultiMesh.TRANSFORM_3D;
	
	multi_mesh_instance_3d_labels.multimesh.instance_count = 0;
	multi_mesh_instance_3d_labels.multimesh.use_colors = true;
	multi_mesh_instance_3d_labels.multimesh.use_custom_data = true;
	multi_mesh_instance_3d_labels.multimesh.transform_format = MultiMesh.TRANSFORM_3D;
	
	var instanced_bomba: MeshInstance3D = BOMBA_AZCACOYO_01.instantiate().get_child(0);
	var instanced_sphere: MeshInstance3D = ETIQUETA_PERFIL_3D.instantiate().get_child(0);
	
	var quad_mesh: Mesh = QuadMesh.new();
	quad_mesh.size = Vector2(0.075, 0.075)  # Tamaño del quad
	quad_mesh.orientation = PlaneMesh.FACE_Z  # Orientación frontal
	quad_mesh.center_offset = Vector3(0, 0, 0)
	quad_mesh.flip_faces = false
	quad_mesh.material = material_label;
		
	var i = 0;
	var estacion: Estacion;
	var meshes = posiciones_coyo_azc.get_children();
	var base_transform_bomba = Transform3D.IDENTITY;
	var base_transform_sphere = Transform3D.IDENTITY;
	var base_transform_labels = Transform3D.IDENTITY;
	var base_transform_poi = Transform3D.IDENTITY;
	
	multi_mesh_instance_3d_bombas.multimesh.instance_count = meshes.size();
	multi_mesh_instance_3d_bombas.multimesh.mesh = instanced_bomba.mesh;
	multi_mesh_instance_3d_bombas.material_override = material_bomba
	
	multi_mesh_instance_3d_esferas.multimesh.instance_count = meshes.size();
	multi_mesh_instance_3d_esferas.multimesh.mesh = instanced_sphere.mesh;
	multi_mesh_instance_3d_esferas.material_override = material_sphere
	
	multi_mesh_instance_3d_labels.multimesh.instance_count = meshes.size();
	multi_mesh_instance_3d_labels.multimesh.mesh = quad_mesh;
	multi_mesh_instance_3d_labels.material_override = material_label;
	
	for child in meshes:
		if child is MeshInstance3D:
			if child.name.contains('_'):
				var id_proyecto = int(child.name.split("_")[1]);
				var id_estacion = int(child.name.split("_")[2]);
				var id_signal_bomba: int = 0;
				
				estacion = GlobalData.get_estacion(id_estacion, id_proyecto);
				
				for _signal: Señal in estacion.signals.values():
					if _signal.tipo_signal == TIPO_SIGNAL.Tipo_Signal.Bomba:
						id_signal_bomba = _signal.id_signal
						break;

				base_transform_bomba = Transform3D.IDENTITY;
				base_transform_bomba.origin = child.position
				base_transform_bomba.basis = Basis.from_euler(Vector3(0,0,0))
				
				base_transform_sphere = Transform3D.IDENTITY;
				base_transform_sphere.origin = child.position
				base_transform_sphere.basis = Basis.from_euler(Vector3(0,0,0))
				
				base_transform_labels = Transform3D.IDENTITY;
				base_transform_labels.origin = child.position + Vector3(0.0,0.0,-0.01)
				base_transform_labels.basis = Basis.from_euler(Vector3(0,0,0))
				
				var area = Area3D.new()
				area.input_ray_pickable = true 

				var collision_shape : CollisionShape3D = CollisionShape3D.new()
				collision_shape.shape = instanced_sphere.mesh.create_convex_shape()
				
				var static_body : StaticBody3D = StaticBody3D.new()
				static_body.transform = base_transform_sphere
				#static_body.visible = false;

				area.add_child(collision_shape);
				static_body.add_child(area);
				multi_mesh_instance_3d_esferas.add_child(static_body)
				area.input_event.connect(_on_area_3d_input_event.bind(i))
				
				multi_mesh_instance_3d_bombas.multimesh.set_instance_transform(i, base_transform_bomba)
				multi_mesh_instance_3d_esferas.multimesh.set_instance_transform(i, base_transform_sphere)
				multi_mesh_instance_3d_labels.multimesh.set_instance_transform(i, base_transform_labels)
				
				multi_mesh_instance_3d_labels.multimesh.set_instance_custom_data(i, Color(id_estacion / 255.0, 0, 0, 0))
				
				diccionario_sitios[i] = {
					"id_proyecto": id_proyecto,
					"id_estacion": id_estacion,
					"id_signal_bomba": id_signal_bomba,
					"position_label": base_transform_labels.origin.y
				}
				
				base_transform_poi = child.global_transform;
				base_transform_poi.origin = child.position + Vector3(0.0, 0.0, 0.5)
				base_transform_poi.basis = Basis.from_euler(Vector3(deg_to_rad(-35.2),0,0)) # es la minima rotacion por perfil_camera script
				
				GlobalSignals.on_agregar_poi_perfil.emit(id_estacion, id_proyecto, base_transform_poi);
				child.queue_free();
				i += 1;
				
	GlobalSignals.connect_on_update_app(_on_update_app, true)
	_on_update_app();
	
func _exit_tree() -> void:
	GlobalSignals.connect_on_update_app(_on_update_app, false)
				
func _on_area_3d_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int, instance_index: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		tiempo_click = Time.get_ticks_msec() / 1000.0
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		var tiempo_actual = Time.get_ticks_msec() / 1000.0
		var intervalo = tiempo_actual - tiempo_click
	
		if intervalo < UMBRAL_SINGLE_CLICK:
			var dic_elem = diccionario_sitios.get(instance_index);
			GlobalSignals.on_mini_site_clicked.emit(dic_elem.id_estacion, dic_elem.id_proyecto)

func _on_update_app():
	var i = 0;
	var estacion: Estacion;
	var signal_bomba: Señal;
	
	for dic in diccionario_sitios.values():
		estacion = GlobalData.get_estacion(dic.id_estacion, dic.id_proyecto);
		signal_bomba = estacion.signals.get(dic.id_signal_bomba);
	
		var color = signal_bomba.get_color_bomba_vec4()
		
		multi_mesh_instance_3d_bombas.multimesh.set_instance_custom_data(i, Color(color.x, color.y, color.z, color.w))
		multi_mesh_instance_3d_esferas.multimesh.set_instance_custom_data(i, Color(color.x, color.y, color.z, color.w))
		
		i += 1;

func _process(_delta: float):
	for i in diccionario_sitios.keys():
		var camera_pos = camera_3d_perfil.global_position
		var _transform = multi_mesh_instance_3d_labels.multimesh.get_instance_transform(i)
		var world_pos = global_transform * _transform.origin
		
		var look_dir = (camera_pos - world_pos).normalized()
		_transform.basis = Basis.looking_at(-look_dir, Vector3.UP)
		
		#var distance = world_pos.distance_to(camera_pos)
		#var distance_factor = clamp(distance / 10.0, 0.0, 1.0)
		#var offset_y = 0.1 * distance_factor
		#
		#_transform.origin.y = diccionario_sitios.get(i).position_label + offset_y
		
		multi_mesh_instance_3d_labels.multimesh.set_instance_transform(i, _transform)
