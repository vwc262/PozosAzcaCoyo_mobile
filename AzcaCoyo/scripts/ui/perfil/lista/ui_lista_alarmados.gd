extends Node

@onready var preventivo_text = %Preventivo_text
@onready var preventivo_texture = %PreventivoTexture

@onready var critico_text = %Critico_text
@onready var critico_texture = %CriticoTexture

var estaciones: Array[Estacion]

var colores = {
	0: Color("ffd300"),
	1: Color("ff5c4b"),
	3: Color("6a6a6a")
}

func _ready() -> void:
	GlobalSignals.connect_on_update_app(_on_update, true)

func _exit_tree() -> void:
	GlobalSignals.connect_on_update_app(_on_update, false)

func set_data_estacion(_estaciones: Array) -> void:
	estaciones = _estaciones
	_on_update()

func _on_update() -> void:
	var preventivo = 0
	var critico = 0
	var e_preventivo = TIPO_ALERTA.ENUM_ALERTA.PREVENTIVO
	var e_critico = TIPO_ALERTA.ENUM_ALERTA.CRITICO

	for estacion in estaciones:
		var alerta = GlobalData.get_estado_alarmado(estacion)
		if alerta == e_preventivo:
			preventivo += 1
		elif alerta == e_critico:
			critico += 1

	preventivo_texture.modulate = colores[0] if preventivo > 0 else colores[3]
	critico_texture.modulate = colores[1] if critico > 0 else colores[3]
	preventivo_text.text = str(preventivo)
	critico_text.text = str(critico)
