extends Node

@export var scene_lista_signal: PackedScene

@onready var signals_container = %SignalsContainer

@onready var lbl_id_sitio = %lbl_id_sitio
@onready var lbl_nombre_sitio = %lbl_nombre_sitio
@onready var lbl_fecha_sitio = %lbl_fecha_sitio
@onready var enlace = %enlace

var enlace_color = {
	false: Color("ff4838"),
	true: Color("00ff00")
}

var estacion: Estacion
var particular_name: String

func _ready() -> void:
	GlobalSignals.connect_on_update_app(_on_update, true)

func _exit_tree() -> void:
	GlobalSignals.connect_on_update_app(_on_update, false)

func set_data_estacion(_estacion: Estacion) -> void:
	estacion = _estacion
	set_data()
	_on_update()

func set_data() -> void:
	lbl_id_sitio.text = str(estacion.id_estacion)
	lbl_nombre_sitio.text = estacion.nombre
	
	var regex = RegEx.new()
	regex.compile("[^\\wáéíóúÁÉÍÓÚñÑüÜ]")  # Elimina todo menos lo especificado
	particular_name = "{0}_{1}".format([str(estacion.id_estacion).pad_zeros(2), regex.sub(estacion.abreviacion.to_lower(), "", true) ])

	for nivel: Señal in estacion.signals.values():
		if nivel.tipo_signal == 1:
			var elemento:= scene_lista_signal.instantiate()
			if not elemento is Control:
				push_error("La escena instanciada no es un nodo de tipo Control")
				continue
			signals_container.add_child(elemento)
			elemento.set_data_signal(nivel)

func get_size() -> float:
	return signals_container.get_combined_minimum_size().y

func _on_update() -> void:
	enlace.modulate = enlace_color[estacion.is_estacion_en_linea()]
	lbl_fecha_sitio.text = GlobalUtils.formatear_fecha(estacion.tiempo)

func _on_go_to_particular_button_up():
	GlobalData.selected_particular = estacion.id_estacion
	GlobalSceneManager.load_particular(particular_name)
	GlobalUiManager.mostrar_modulo(TIPO_MODULO.UI.PARTICULAR);
