extends Node

@onready var mosaico_text = %mosaico_text
@onready var mapa_text = %Mapa_text
@onready var estructuras_text = %Estructuras_text

var aux_module: TIPO_MODULO.UI;

func _ready() -> void:
	aux_module = TIPO_MODULO.UI.MAPA
	GlobalSignals.connect_on_ui_change(_on_ui_change, true)

func _exit_tree() -> void:
	GlobalSignals.connect_on_ui_change(_on_ui_change, false)
	
func _on_btn_estructuras_button_down() -> void:
	change_visibility_buttons(true, false, false)
	GlobalUiManager.mostrar_modulo(TIPO_MODULO.UI.ESTRUCTURAS);

func _on_btn_mapa_button_down() -> void:
	change_visibility_buttons(false, true, false)
	GlobalUiManager.mostrar_modulo(TIPO_MODULO.UI.MAPA);

func _on_btn_mosaico_button_down() -> void:
	change_visibility_buttons(false, false, true)
	GlobalUiManager.mostrar_modulo(TIPO_MODULO.UI.MOSAICOS);

func change_visibility_buttons(estructuras, mapa, mosaico) -> void:
	estructuras_text.visible = true if estructuras else false
	mapa_text.visible = true if mapa else false
	mosaico_text.visible = true if mosaico else false
	
func _on_ui_change(tipo_modulo:TIPO_MODULO.UI):
	if tipo_modulo == TIPO_MODULO.UI.PARTICULAR:
		change_visibility_buttons(false, false, false)
	else:
		GlobalSceneManager.load_perfil()
