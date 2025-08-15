extends Camera3D
class_name TouchCameraController

@export_category("Configuracion Navegacion")
@export var zoom_speed: float = 1.0
@export var pan_speed: float = 0.75
@export var minPanSpeed: float = 0.075
@export var maxPanSpeed: float = 0.375
@export var can_pan: bool = true;
@export var can_zoom: bool = true;
@export var treshold_reset_camera : int = 0

# Límites del zoom
@export_category("Configuracion Zoom")
@export var min_zoom: float = 1.0
@export var max_zoom: float = 11.0
@export var min_zoom_inclination: float = 5
@export var max_zoom_inclination: int = -15;

# Límites del panning
@export_category("Configuracion Paneo")
@export var min_pan_x: float = -2.1
@export var max_pan_x: float = 2.2
@export var min_pan_z: float = -2.4
@export var max_pan_z: float = 4.3

var inclination: int = 0
var initial_camera_inclination : float
var touch_points: Dictionary = {}
var start_distance: float = 0.0
var previous_dist: float = 0.0
var start_zoom: float = 0.0
var start_angle: float = 0.0
var initial_transform : Transform3D
var initial_position: Vector3;
var movement_signal_emitted: bool = false;

func guardar_posicion_inicial():
	initial_transform = transform
	initial_position = global_position;
	initial_camera_inclination = rotation_degrees.x
	
	GlobalSignals.on_agregar_poi_perfil.emit(0, global_transform)
	
func _ready() -> void:
	
	GlobalData.min_zoom = min_zoom
	GlobalData.max_zoom = max_zoom
	
	guardar_posicion_inicial()
	
	GlobalSignals.connect_on_desactivar_eventos(_on_desactivar_eventos, true)
	GlobalSignals.connect_on_mini_site_clicked(_on_mini_site_clicked, true)
	
func _exit_tree() -> void:
	GlobalSignals.connect_on_desactivar_eventos(_on_desactivar_eventos, false)
	GlobalSignals.connect_on_mini_site_clicked(_on_mini_site_clicked, false)

func _input(event: InputEvent) -> void:
	pan_speed = lerp(minPanSpeed * 0.01 ,maxPanSpeed * 0.01,remap(position.y,max_zoom,min_zoom,1,0))

	if event is InputEventScreenTouch:
		handle_touch(event)
	elif event is InputEventScreenDrag:
		handle_drag(event)

	handle_mouse_zoom(event)

func handle_mouse_zoom(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			handle_zoom(-event.factor * 7)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			handle_zoom(event.factor * 7)
	
# Manejo de toques en pantalla
func handle_touch(event: InputEventScreenTouch):
	if event.pressed:
		touch_points[event.index] = event.position
	else:
		touch_points.erase(event.index)

	if touch_points.size() == 2:
		var touch_point_positions = touch_points.values()
		start_distance = touch_point_positions[0].distance_to(touch_point_positions[1])
		previous_dist = start_distance
		start_angle = get_angle(touch_point_positions[0], touch_point_positions[1])
		start_zoom = global_transform.origin.distance_to(Vector3.ZERO)
	elif touch_points.size() < 2:
		start_distance = 0

# Manejo de gestos de arrastre
func handle_drag(event: InputEventScreenDrag):
	touch_points[event.index] = event.position

	if touch_points.size() == 1 and can_pan:
		handle_pan(event)
	elif touch_points.size() == 2:
		var touch_point_positions = touch_points.values()
		var current_dist = touch_point_positions[0].distance_to(touch_point_positions[1])
		var _current_angle = get_angle(touch_point_positions[0], touch_point_positions[1])

		if can_zoom:
			var dir = -sign(current_dist - previous_dist)
			handle_zoom(dir)
			
		previous_dist = current_dist
	
	apply_pan_limits()

# Manejo del PAN (desplazamiento de la cámara)
func handle_pan(event: InputEventScreenDrag):
	var pan_vector = Vector3(event.relative.x, 0, event.relative.y)
	pan_vector = pan_vector.rotated(Vector3.UP, rotation.y)
	global_translate(-pan_vector * pan_speed)

func apply_pan_limits():
	var local_pos = global_transform.origin

	local_pos.x = clamp(local_pos.x, min_pan_x, max_pan_x)
	local_pos.z = clamp(local_pos.z, min_pan_z, max_pan_z)

	global_transform.origin = local_pos

# Manejo del ZOOM (acercamiento/alejamiento de la cámara)
func handle_zoom(dir:int) -> void:
	var zoom_direction = dir * zoom_speed * get_process_delta_time()
	var vector_inclinado = Vector3.UP;
	
	var positionaux = position + (vector_inclinado) * zoom_direction
	var rotated_vector = Vector3(positionaux.x,positionaux.y,positionaux.z)
	rotated_vector.y = clampf(rotated_vector.y,min_zoom,max_zoom);
	
	#var v0 = initial_position;
	#v0.x = 0;
	#v0.z = 0;
	#
	#var v1 = global_position;
	#v1.x = 0;
	#v1.z = 0;
	#
	#var dist = v1.distance_to(v0)
	
	#if dist > 1 and !movement_signal_emitted:
		#movement_signal_emitted = true;
		#GlobalSignals.on_camera_leave_initial_position.emit()
	#elif dist < 0.35 and movement_signal_emitted:
		#GlobalSignals.on_camera_reset_position.emit()
		#movement_signal_emitted = false;
		
	apply_zoom_limits(rotated_vector, positionaux)

# Aplicar límites al ZOOM
func apply_zoom_limits(rotated_vector, positionaux):
	if rotated_vector.y > min_zoom && rotated_vector.y < max_zoom:
		position = positionaux

		var t = remap(positionaux.y, min_zoom, max_zoom, 0, 1)
		var w = exp(-4 * t)
		rotation_degrees.x = lerp(initial_camera_inclination, max_zoom_inclination * 1.0, w)
	
# Cálculo del ángulo entre dos puntos
func get_angle(position_1: Vector2, position_2: Vector2) -> float:
	var delta = position_2 - position_1
	return atan2(delta.y, delta.x)

func _on_desactivar_eventos(desactivar: bool):
	set_process_input(!desactivar)

func _on_mini_site_clicked(_id_estacion: int):
	movement_signal_emitted = true
