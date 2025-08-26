extends Node3D

# Configuración de sensibilidad y límites
@export var mouse_sensitivity: float = 0.002
@export var touch_sensitivity: float = 0.005
@export var rotation_speed: float = 5.0

# Límites de rotación en grados
@export var min_x_rotation: float = -80.0
@export var max_x_rotation: float = 80.0
@export var min_y_rotation: float = -360.0
@export var max_y_rotation: float = 360.0

# Distancia de la cámara al pivote
@export var camera_distance: float = 5.0
@export var min_distance: float = 2.0
@export var max_distance: float = 20.0

# Variables internas
var rotation_x: float = 0.0
var rotation_y: float = 0.0
var target_rotation: Vector2 = Vector2.ZERO
var current_distance: float = 5.0

# Referencia a la cámara
@onready var camera: Camera3D = $Camera3D

func _ready():
	# Configurar distancia inicial
	current_distance = camera_distance
	update_camera_position()
	
	# Configurar procesamiento de input
	set_process_input(true)
	set_process(true)

func _input(event):
	# Control con mouse
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		handle_mouse_input(event)
	
	# Control con touch (móvil)
	if event is InputEventScreenDrag:
		handle_touch_input(event)
	
	# Zoom con rueda del mouse
	if event is InputEventMouseButton:
		handle_zoom_input(event)

func handle_mouse_input(event: InputEventMouseMotion):
	rotation_y -= event.relative.x * mouse_sensitivity
	rotation_x -= event.relative.y * mouse_sensitivity
	
	# Aplicar límites de rotación
	rotation_x = clamp(rotation_x, deg_to_rad(min_x_rotation), deg_to_rad(max_x_rotation))
	rotation_y = clamp(rotation_y, deg_to_rad(min_y_rotation), deg_to_rad(max_y_rotation))
	
	target_rotation = Vector2(rotation_x, rotation_y)

func handle_touch_input(event: InputEventScreenDrag):
	# Para touch usamos un dedo para rotar
	if event.get_index() == 0:
		rotation_y -= event.relative.x * touch_sensitivity
		rotation_x -= event.relative.y * touch_sensitivity
		
		# Aplicar límites de rotación
		rotation_x = clamp(rotation_x, deg_to_rad(min_x_rotation), deg_to_rad(max_x_rotation))
		rotation_y = clamp(rotation_y, deg_to_rad(min_y_rotation), deg_to_rad(max_y_rotation))
		
		target_rotation = Vector2(rotation_x, rotation_y)
	
	# Para zoom con pinch (dos dedos)
	elif event.get_index() == 1:
		# Esta parte manejaría el zoom con pinch, puedes implementarlo si lo necesitas
		pass

func handle_zoom_input(event: InputEventMouseButton):
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		current_distance = max(min_distance, current_distance - 1.0)
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		current_distance = min(max_distance, current_distance + 1.0)
	
	update_camera_position()

func _process(delta):
	# Suavizar la rotación
	var current_rot = Vector2(rotation.x, rotation.y)
	var new_rotation = current_rot.lerp(target_rotation, rotation_speed * delta)
	
	rotation.x = new_rotation.x
	rotation.y = new_rotation.y
	
	# Actualizar posición de la cámara
	update_camera_position()

func update_camera_position():
	# Posicionar la cámara atrás del objeto mirando hacia él
	camera.position = Vector3(0, 0, current_distance)
	camera.look_at(global_position)

# Funciones públicas para control desde otros scripts
func set_camera_distance(distance: float):
	current_distance = clamp(distance, min_distance, max_distance)
	update_camera_position()

func get_camera_distance() -> float:
	return current_distance

func reset_rotation():
	rotation_x = 0.0
	rotation_y = 0.0
	target_rotation = Vector2(rotation_x, rotation_y)
