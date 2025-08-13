extends Node

const UI_MAPA = preload("res://scenes/ui/ui_mapa/ui_mapa.tscn")
const UI_PARTICULAR = preload("res://scenes/ui/ui_particular/ui_particular.tscn")
const UI_MOSAICOS = preload("res://scenes/ui/ui_mosaicos/ui_mosaico.tscn")
const UI_ESTRUCTURAS = preload("res://scenes/ui/ui_estructuras/ui_estructuras.tscn")

var ui_persistente: Node = null
var escena_actual: Node = null
var modulo_actual: TIPO_MODULO.UI = TIPO_MODULO.UI.MAPA;

# Asociación entre módulo y escena
var rutas_modulos := {
	TIPO_MODULO.UI.MAPA: UI_MAPA,
	TIPO_MODULO.UI.MOSAICOS: UI_MOSAICOS,
	TIPO_MODULO.UI.PARTICULAR: UI_PARTICULAR,
	TIPO_MODULO.UI.ESTRUCTURAS: UI_ESTRUCTURAS
}

func inicializar_contenedor(_ui_persistente):
	ui_persistente = _ui_persistente

func mostrar_modulo(modulo: TIPO_MODULO.UI) -> void:
	if not rutas_modulos.has(modulo):
		push_error("UIManager: módulo no registrado.")
		return

	var escena_objetivo = rutas_modulos[modulo]

	# Si ya está cargada, no hacemos nada
	if escena_actual and escena_actual.scene_file_path == escena_objetivo.resource_path:
		return

	# Eliminar escena anterior
	if escena_actual and escena_actual.is_inside_tree():
		ui_persistente.remove_child(escena_actual)
		escena_actual.queue_free()

	# Cargar y agregar nueva
	var nueva_escena = escena_objetivo.instantiate()
	ui_persistente.add_child(nueva_escena)
	escena_actual = nueva_escena
	modulo_actual = modulo

	GlobalSignals.on_ui_change.emit(modulo)
