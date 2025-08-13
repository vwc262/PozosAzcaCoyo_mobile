extends Node

@onready var nombre_signal = %Nombre_signal
@onready var ui_progressbar = %UiProgressbar

var nivel: Señal
var altura: float
var critico: float
var max_value: float

func set_data_signal(_signal: Señal) -> void:
	nivel = _signal
	set_data()

func set_data() -> void:
	nombre_signal.text = nivel.nombre
	ui_progressbar.set_data_nivel(nivel)
