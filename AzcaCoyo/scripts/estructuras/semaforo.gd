extends RefCounted
class_name Semaforo

@export var id_signal: int
@export var normal: float
@export var preventivo: float
@export var critico: float
@export var altura: float

func _init(json):	
	self.normal = json["normal"]
	self.preventivo = json["preventivo"]
	self.critico = json["critico"]
	self.altura = json["altura"]
