extends RefCounted
class_name Linea

@export var id_linea: int
@export var id_estacion: int
@export var nombre: String

func _init(jsonData):
	self.id_linea = jsonData["idLinea"]
	self.id_estacion = jsonData["idEstacion"]
	self.nombre = jsonData["nombre"]
