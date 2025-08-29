extends Node3D

@onready var pois_alcaldias: Node3D = $pois_alcaldias
@onready var mesh_mapa: Node3D = $MeshMapa
@onready var multi_mesh_instance_3d_bombas: MultiMeshInstance3D = %MultiMeshInstance3D_bombas
@onready var multi_mesh_instance_3d_esferas: MultiMeshInstance3D = %MultiMeshInstance3D_esferas
@onready var multi_mesh_instance_3d_palos: MultiMeshInstance3D = %MultiMeshInstance3D_palos
@onready var multi_mesh_instance_3d_labels: MultiMeshInstance3D = %MultiMeshInstance3D_labels

@onready var posiciones_coyo_azc: Node3D = %posiciones_coyoAzc

@export var material_bomba: Material;
@export var material_sphere: Material;
@export var material_palos: Material;
@export var material_label: Material;

var target_point = Vector3(0, 0, 2.5)
var diccionario_sitios: Dictionary = {};
var selected_index: int = -1;
@onready var camera_3d_perfil: TouchCameraController = %Camera3D_Perfil

const MARCADOR_SITIO = preload("res://assets/Prefab/MarcadorSitio.tscn")

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
	
	multi_mesh_instance_3d_palos.multimesh.instance_count = 0;
	multi_mesh_instance_3d_palos.multimesh.use_colors = true;
	multi_mesh_instance_3d_palos.multimesh.use_custom_data = true;
	multi_mesh_instance_3d_palos.multimesh.transform_format = MultiMesh.TRANSFORM_3D;
	
	multi_mesh_instance_3d_labels.multimesh.instance_count = 0;
	multi_mesh_instance_3d_labels.multimesh.use_colors = true;
	multi_mesh_instance_3d_labels.multimesh.use_custom_data = true;
	multi_mesh_instance_3d_labels.multimesh.transform_format = MultiMesh.TRANSFORM_3D;
	
	var instanced_marker: Node3D = MARCADOR_SITIO.instantiate();
	
	var instanced_bomba: MeshInstance3D = instanced_marker.get_node("bomba");
	var instanced_sphere: MeshInstance3D = instanced_marker.get_node("bola");
	var instanced_palo: MeshInstance3D = instanced_marker.get_node("palo");
	
	var quad_mesh_numero: Mesh = QuadMesh.new();
	quad_mesh_numero.size = Vector2(0.075, 0.075)  # Tamaño del quad
	quad_mesh_numero.orientation = PlaneMesh.FACE_Z  # Orientación frontal
	quad_mesh_numero.center_offset = Vector3(0, 0, 0)
	quad_mesh_numero.flip_faces = false
	quad_mesh_numero.material = material_label;
		
	var i = 0;
	var estacion: Estacion;
	var meshes = posiciones_coyo_azc.get_children();
	var base_transform_bomba = Transform3D.IDENTITY;
	var base_transform_sphere = Transform3D.IDENTITY;
	var base_transform_palos = Transform3D.IDENTITY;
	var base_transform_labels = Transform3D.IDENTITY;
	var base_transform_poi = Transform3D.IDENTITY;
	
	multi_mesh_instance_3d_bombas.multimesh.instance_count = meshes.size();
	multi_mesh_instance_3d_bombas.multimesh.mesh = instanced_bomba.mesh;
	multi_mesh_instance_3d_bombas.material_override = material_bomba
	
	multi_mesh_instance_3d_esferas.multimesh.instance_count = meshes.size();
	multi_mesh_instance_3d_esferas.multimesh.mesh = instanced_sphere.mesh;
	multi_mesh_instance_3d_esferas.material_override = material_sphere
	
	multi_mesh_instance_3d_palos.multimesh.instance_count = meshes.size();
	multi_mesh_instance_3d_palos.multimesh.mesh = instanced_palo.mesh;
	multi_mesh_instance_3d_palos.material_override = material_palos
	
	multi_mesh_instance_3d_labels.multimesh.instance_count = meshes.size();
	multi_mesh_instance_3d_labels.multimesh.mesh = quad_mesh_numero;
	multi_mesh_instance_3d_labels.material_override = material_label;
	
	for child in meshes:
		if child is MeshInstance3D:
			if child.name.contains('_'):
				var id_proyecto = int(child.name.split("_")[1]);
				var id_estacion = int(child.name.split("_")[2]);
				var id_signal_bomba: int = 0;
				
				i = id_estacion - 1 + (30 if id_proyecto == 23 else 0)
				
				estacion = GlobalData.get_estacion(id_estacion, id_proyecto);
				
				for _signal: Señal in estacion.signals.values():
					if _signal.tipo_signal == TIPO_SIGNAL.Tipo_Signal.Bomba:
						id_signal_bomba = _signal.id_signal
						break;

				base_transform_bomba = Transform3D.IDENTITY;
				base_transform_bomba.origin = child.position + Vector3(0.002,0.318,0.0)
				base_transform_bomba.basis = Basis.from_euler(Vector3(0,0,0))
				
				base_transform_sphere = Transform3D.IDENTITY;
				base_transform_sphere.origin = child.position + Vector3(0.0,0.412,0.0)
				base_transform_sphere.basis = Basis.from_euler(Vector3(0,0,0))
				
				base_transform_palos = Transform3D.IDENTITY;
				base_transform_palos.origin = child.position + Vector3(0.0,0.370,0.0)
				base_transform_palos.basis = Basis.from_euler(Vector3(0,0,0))
				
				base_transform_labels = Transform3D.IDENTITY;
				base_transform_labels.origin = child.position + Vector3(0.0,0.412,0.00)
				base_transform_labels.basis = Basis.from_euler(Vector3(0,0,0))
				
				var area = Area3D.new()
				area.input_ray_pickable = true 

				var collision_shape : CollisionShape3D = CollisionShape3D.new()
				collision_shape.shape = quad_mesh_numero.create_convex_shape()
				
				var static_body : StaticBody3D = StaticBody3D.new()
				static_body.transform = base_transform_labels
				static_body.scale = Vector3.ONE * 0.75;

				area.add_child(collision_shape);
				static_body.add_child(area);
				multi_mesh_instance_3d_esferas.add_child(static_body)
				area.input_event.connect(_on_area_3d_input_event.bind(i))
				
				multi_mesh_instance_3d_bombas.multimesh.set_instance_transform(i, base_transform_bomba)
				multi_mesh_instance_3d_esferas.multimesh.set_instance_transform(i, base_transform_sphere)
				multi_mesh_instance_3d_palos.multimesh.set_instance_transform(i, base_transform_palos)
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
				
	GlobalSignals.connect_on_update_app(_on_update_app, true)
	GlobalSignals.connect_on_mini_site_clicked(_on_site_row_clicked, true)
	_on_update_app();
	
func _exit_tree() -> void:
	GlobalSignals.connect_on_update_app(_on_update_app, false)
	GlobalSignals.connect_on_mini_site_clicked(_on_site_row_clicked, false)
				
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
		
		i = get_actual_index(dic.id_estacion, dic.id_proyecto);
	
		var color = signal_bomba.get_color_bomba_vec4()
		
		multi_mesh_instance_3d_bombas.multimesh.set_instance_custom_data(i, Color(color.x, color.y, color.z, 0.0))
		multi_mesh_instance_3d_esferas.multimesh.set_instance_custom_data(i, Color(color.x, color.y, color.z, ( 1.0 if selected_index == i else 0.0)))

func _process(_delta: float):
	for i in diccionario_sitios.keys():
		var camera_pos = camera_3d_perfil.global_position
		var _transform_label = multi_mesh_instance_3d_labels.multimesh.get_instance_transform(i)
		var _transform_sphere = multi_mesh_instance_3d_esferas.multimesh.get_instance_transform(i)
		var _transform_bomba = multi_mesh_instance_3d_bombas.multimesh.get_instance_transform(i)
		
		var world_pos = global_transform * _transform_label.origin
		var look_dir = (camera_pos - world_pos).normalized()
		
		_transform_label.basis = Basis.looking_at(-look_dir, Vector3.UP)
		_transform_sphere.basis = Basis.looking_at(-look_dir, Vector3.UP)
		_transform_bomba.basis = Basis.looking_at(-look_dir, Vector3.UP)
		
		var euler_angles = _transform_sphere.basis.get_euler()
		_transform_sphere.basis = Basis.from_euler(Vector3(euler_angles.x, 0, euler_angles.z))
		
		euler_angles = _transform_label.basis.get_euler()
		_transform_label.basis = Basis.from_euler(Vector3(euler_angles.x, 0, euler_angles.z))
		
		euler_angles = _transform_bomba.basis.get_euler()
		_transform_bomba.basis = Basis.from_euler(Vector3(euler_angles.x, 0, euler_angles.z))

		multi_mesh_instance_3d_labels.multimesh.set_instance_transform(i, _transform_label)
		multi_mesh_instance_3d_esferas.multimesh.set_instance_transform(i, _transform_sphere)
		multi_mesh_instance_3d_bombas.multimesh.set_instance_transform(i, _transform_bomba)

func _on_site_row_clicked(_id_estacion: int, _id_proyecto: int):
	selected_index = get_actual_index(_id_estacion, _id_proyecto);
	_on_update_app();
	
func get_actual_index(_id_estacion: int, _id_proyecto: int) -> int:
	var index = -1;
	
	if _id_estacion != 0 && _id_proyecto != 0:
		if _id_proyecto == 22:
			index = _id_estacion - 1;
		else:
			index = 30 + _id_estacion - 1;
	else:
		index = -1;
		
	return index;
