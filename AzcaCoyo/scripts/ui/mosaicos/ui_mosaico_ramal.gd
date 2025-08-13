extends Node

var interceptor: int;
var online_count: int;
var offline_count: int;
var total_estaciones: int;

var TARJETA = preload("res://scenes/ui/ui_mosaicos/ui_mosaico_tarjeta.tscn")
var TARJETA_DUMMY = preload("res://scenes/ui/ui_mosaicos/ui_mosaico_tarjeta_dummy.tscn")

@onready var container = %HBoxContainer
@onready var nombre_interceptor = %lbl_nombre_interceptor
@onready var lbl_online_valor = %lbl_online_valor
@onready var lbl_offline_valor = %lbl_offline_valor
@onready var tr_interceptor: TextureRect = %tr_interceptor

func initialize(_interceptor: int):
	interceptor = _interceptor

func _ready() -> void:
	var estaciones = GlobalData.get_all_data();
	nombre_interceptor.text = GlobalData.get_name_interceptor(interceptor)
	tr_interceptor.modulate = GlobalData.get_color_interceptor(interceptor)
	
	for estacion:Estacion in estaciones:
		if estacion.tipo_interceptor == interceptor:
			total_estaciones += 1
			var instanced_scene = TARJETA.instantiate()
			instanced_scene.initialize(estacion)
			
			container.add_child(instanced_scene);
			
	if total_estaciones == 0:
		self.queue_free();
	else:
		for i in range(total_estaciones, 3):
			var instanced_scene = TARJETA_DUMMY.instantiate()
			container.add_child(instanced_scene);
		
		GlobalSignals.connect_on_update_app(_on_update_app, true)
		_on_update_app()
	
func _on_update_app():
	online_count = 0;
	var estaciones = GlobalData.get_all_data();
	
	for estacion:Estacion in estaciones:
		if estacion.tipo_interceptor == interceptor:
			online_count += 1 if estacion.is_estacion_en_linea() else 0
			
	offline_count = total_estaciones - online_count;
	
	lbl_online_valor.text = str(online_count)
	lbl_offline_valor.text = str(offline_count)
