extends Control

@onready var id = %ID
@onready var name_site = %name_site
@onready var direccion = %direccion

var latitud: String
var longitud: String
var lat_lng: String

func _ready() -> void:
	GlobalSignals.connect_on_mini_site_clicked(_on_mini_site_clicked, true)
	GlobalSignals.connect_on_row_site_clicked_at_particular(_on_mini_site_clicked, true)
	
func _exit_tree() -> void:
	GlobalSignals.connect_on_mini_site_clicked(_on_mini_site_clicked, false)
	GlobalSignals.connect_on_row_site_clicked_at_particular(_on_mini_site_clicked, false)

func _on_mini_site_clicked(_id_estacion: int, _id_proyecto: int):
	if _id_estacion != 0 && _id_proyecto != 0:
		var estacion = GlobalData.get_estacion(_id_estacion, _id_proyecto)
		id.text = str(estacion.id_estacion)
		name_site.text = estacion.nombre
		lat_lng = "%s,%s" % [estacion.direccion.latitud, estacion.direccion.longitud]

func _on_button_pressed():
	var path_maps: String = "https://www.google.com/maps?q="
	path_maps = path_maps + lat_lng
	OS.shell_open(path_maps)
