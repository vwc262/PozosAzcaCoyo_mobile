extends Node

#@export var No_disponble: Label3D

var id_estacion: int
var estacion: Estacion
var id_signal: int
var ordinal: int
var indice: String
var altura: float
var nivel: Señal
var valor: float = 0.0
var valor_agua: float = 0.0
var dir: int = 0
var velocidad_suavizado: float = 2.0 
var socket_top: Node3D
var socket_bottom: Node3D

@onready var agua_mesh: MeshInstance3D = $"."

func _process(delta):
	# Calculamos la posición objetivo basada en valor_agua
	var posicion_objetivo = remap(
		valor_agua,
		0.0, 1.0,
		socket_bottom.position.y, socket_top.position.y)

	# Movemos suavemente hacia la posición objetivo usando lerp
	agua_mesh.position.y = lerp(
		agua_mesh.position.y,
		posicion_objetivo,
		velocidad_suavizado * delta)

func update() -> void:
	estacion = GlobalData.get_estacion(id_estacion)
	nivel = estacion.signals.get(id_signal)

	altura = 10.0 if nivel.semaforo == null else nivel.semaforo.altura
	dir = 1 if nivel.valor > valor else -1
	valor = nivel.valor if nivel.dentro_rango else altura
	valor_agua = clamp(valor / altura, 0, 1)
	
	#if No_disponble:
		#No_disponble.visible = false if nivel.dentro_rango else true

func _ready() -> void:
	GlobalSignals.connect_on_particular_loaded(_on_particular_loaded, true)
	
func _exit_tree() -> void:
	GlobalSignals.connect_on_particular_loaded(_on_particular_loaded, false)
	GlobalSignals.connect_on_update_app(update, false)

func _on_particular_loaded(_id_estacion: int):
	ordinal = 0 if name.contains('1') else 1 if name.contains('2') else 2 if name.contains('3') else 3
	indice = "a" if ordinal == 0 else "b" if ordinal == 1 else "c" if ordinal == 2 else "d"
	
	id_estacion = _id_estacion
	estacion = GlobalData.get_estacion(id_estacion)
	
	for _signal: Señal in estacion.signals.values():
		if _signal.tipo_signal == TIPO_SIGNAL.Tipo_Signal.Nivel:
			if _signal.ordinal == ordinal:
				id_signal = _signal.id_signal
				break;
	
	if id_signal == 0:
		print("no se encontró el id signal del nivel ", ordinal + 1)
		return;
		
	# aqui quiero obtener los sockets para que no se pongan a manita
	for child in get_parent().get_children():
		var name_splitted = child.name.to_lower().split('_')
		if name_splitted.size() > 1:
			if name_splitted[1].contains(indice):
				if name_splitted[1].contains("0"):
					socket_bottom = child
				elif name_splitted[1].contains("1"):
					socket_top = child
	
	if socket_bottom == null:
		print("socket_bottom no encontrado")
		return
	if socket_top == null:
		print("socket_top no encontrado")
		return
	
	update()
	GlobalSignals.connect_on_update_app(update, true)
