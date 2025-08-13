extends Node

@onready var ui_contenedor_persistente: Panel = %ui_contenedor_persistente

func _ready():
	GlobalUiManager.inicializar_contenedor(ui_contenedor_persistente)
	GlobalUiManager.mostrar_modulo(TIPO_MODULO.UI.MAPA)
