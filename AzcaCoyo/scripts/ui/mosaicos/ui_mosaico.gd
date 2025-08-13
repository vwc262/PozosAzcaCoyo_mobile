extends Node

var CATEGORIA_RAMAL = preload("res://scenes/ui/ui_mosaicos/ui_mosaico_categoria_ramal.tscn")
@onready var container = %tarjetas_container

func _ready() -> void:
	for interceptor in range(18):
		var instanced_scene = CATEGORIA_RAMAL.instantiate();
		instanced_scene.initialize(interceptor + 1);
		container.add_child(instanced_scene)
