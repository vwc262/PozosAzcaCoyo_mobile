extends Node

@onready var lbl_sitios_online: Label = %lbl_sitios_online_valor
@onready var lbl_sitios_offline: Label = %lbl_sitios_offline_valor

var estaciones: Array
var total_sitios: int

func _ready() -> void:
	GlobalSignals.connect_on_update_app(_on_update, true)
	estaciones = GlobalData.get_all_data()
	total_sitios = estaciones.size()
	_on_update()

func _exit_tree() -> void:
	GlobalSignals.connect_on_update_app(_on_update, false)

func _on_update() -> void:
	var total_online = GlobalData.get_total_online(estaciones)
	var total_offline = total_sitios - total_online

	lbl_sitios_online.text = str(total_online)
	lbl_sitios_offline.text = str(total_offline)
