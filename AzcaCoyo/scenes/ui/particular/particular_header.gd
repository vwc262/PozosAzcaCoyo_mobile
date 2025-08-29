extends Control

@onready var id = %ID
@onready var name_site = %name_site
@onready var direccion = %direccion

func _ready() -> void:
	GlobalSignals.connect_on_mini_site_clicked(_on_mini_site_clicked, true)
	GlobalSignals.connect_on_row_site_clicked_at_particular(_on_mini_site_clicked, true)
	
func _exit_tree() -> void:
	GlobalSignals.connect_on_mini_site_clicked(_on_mini_site_clicked, false)
	GlobalSignals.connect_on_row_site_clicked_at_particular(_on_mini_site_clicked, false)

func _on_mini_site_clicked(_id_estacion: int, _id_proyecto: int):
	if _id_estacion != 0 && _id_proyecto != 0:
		var estacion = GlobalData.get_estacion(_id_estacion, _id_proyecto)
