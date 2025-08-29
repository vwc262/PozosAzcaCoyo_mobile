extends RefCounted
class_name Lat_Lng

@export var id_estacion: int
@export var id_proyecto: int
@export var latitud: String
@export var longitud: String

#Constructor Lat_Lng
func _init(jsonData):
	self.id_estacion = jsonData["idEstacion"]
	self.id_proyecto = jsonData["idproyecto"]
	self.latitud = str(jsonData["latitud"])
	self.longitud = str(jsonData["longitud"])
