extends Node

@onready var btn_izq: Button = %btn_izq
@onready var btn_der: Button = %btn_der
@onready var elementos_contenedor: HBoxContainer = %elementos_contenedor
@onready var scroll_elementos_container: ScrollContainer = %scroll_elementos_container
@onready var lbl_total_alertados: Label = %lbl_total_alertados

@export var scroll_step := 200  # Cantidad de píxeles a mover por clic
@export var scroll_duration := 0.2  # Duración de la animación (en segundos)

var tween: Tween

func _ready() -> void:
	_update_total_alertados()

func _update_total_alertados() -> void:
	lbl_total_alertados.text = str(elementos_contenedor.get_child_count())

func _on_btn_izq_pressed() -> void:
	_scroll_horizontal(-scroll_step)

func _on_btn_der_pressed() -> void:
	_scroll_horizontal(scroll_step)

func _scroll_horizontal(delta: int) -> void:
	var current_offset = scroll_elementos_container.scroll_horizontal
	var max_offset = scroll_elementos_container.get_h_scroll_bar().max_value
	var target_offset = clamp(current_offset + delta, 0, max_offset)

	if tween and tween.is_running():
		tween.kill()

	tween = create_tween()
	tween.tween_property(scroll_elementos_container, "scroll_horizontal", target_offset, scroll_duration)
	await tween.finished
	tween.kill()
