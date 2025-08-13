extends Node

@export var scene_lista_ramal: PackedScene

@onready var ui_lista: Control = $"."
@onready var elementos_contenedor: VBoxContainer = %elementos_contenedor

var ancho_expandido: int = 600
var ancho_colapsado: int = 50
var esta_expandido: bool = true

var inteceptor: String
var color: Color

var estaciones: Array = GlobalData.get_all_data()

func _ready() -> void:
	_limpiar_lista() # solo la primera vez
	_append_ramales_lista()

# Elimina todos los elementos actuales del contenedor
func _limpiar_lista() -> void:
	for child in elementos_contenedor.get_children():
		child.queue_free()

func _append_ramales_lista() -> void:
	for i in range(18):
		inteceptor = GlobalData.get_name_interceptor(i+1)
		color = GlobalData.get_color_interceptor(i+1)
		var elemento: Control = scene_lista_ramal.instantiate()
		var _estaciones: Array[Estacion] = []

		for estacion: Estacion in estaciones:
			if estacion.interceptor == inteceptor:
				_estaciones.append(estacion)
		if _estaciones.size() > 0:
			elementos_contenedor.add_child(elemento)
			elemento.set_nombre_interceptor(inteceptor)
			elemento.set_color_interceptor(color)
			elemento.set_estacion_data(_estaciones)
