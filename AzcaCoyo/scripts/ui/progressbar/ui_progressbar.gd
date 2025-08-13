extends Node

@onready var lbl_nivel: Label = %lbl_nivel
@onready var altura_txt: Label = %lbl_altura
@onready var normal_txt: Label = %lbl_norm
@onready var preventivo_txt: Label = %lbl_prev
@onready var critico_txt: Label = %lbl_crit
@onready var nivel_progress_bar: TextureProgressBar = %progress_nivel

var nivel: Señal
var altura: float
var normal: float
var preventivo: float
var critico: float

func _ready() -> void:
	GlobalSignals.connect_on_update_app(_on_update, true)

func _exit_tree() -> void:
	GlobalSignals.connect_on_update_app(_on_update, false)

func set_data_nivel(_nivel: Señal) -> void:
	nivel = _nivel
	altura = nivel.semaforo.altura
	normal = nivel.semaforo.normal
	preventivo = nivel.semaforo.preventivo
	critico = nivel.semaforo.critico
	nivel_progress_bar.max_value = altura

	altura_txt.text = "Altura {0}".format([altura])
	normal_txt.text = "Normal: {0}".format([normal])
	preventivo_txt.text = "Preventivo: {0}".format([preventivo])
	critico_txt.text = "Crítico: {0}".format([critico])

	_on_update()

func _on_update() -> void:
	if nivel:
		lbl_nivel.text = nivel.get_valor_string()
		nivel_progress_bar.value = altura * 0.1 + ( nivel.valor
		if nivel.dentro_rango else altura)
		nivel_progress_bar.tint_progress = nivel.get_color_barra_vida()
