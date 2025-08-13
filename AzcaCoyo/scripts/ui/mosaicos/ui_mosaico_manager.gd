extends Control

@onready var panel_mosaico: Node = $panel_mosaico
@onready var panel_info_mosaico: PanelContainer = %panel_info_mosaico

@onready var tr_enlace: TextureRect = %tr_enlace
@onready var lbl_id: Label = %lbl_id
@onready var lbl_interceptor: Label = %lbl_interceptor
@onready var lbl_bateria: Label = %lbl_bateria
@onready var lbl_nombre: Label = %lbl_nombre
@onready var lbl_fecha: Label = %lbl_fecha
@onready var tr_interceptor: TextureRect = %tr_interceptor

@onready var vbox_estacion: HBoxContainer = %vbox_estacion
@onready var vbox_niveles_container: VBoxContainer = %vbox_niveles_container
@onready var ui_graficador: PanelContainer = %UiGraficador

var info_mosaicos: Array[Node];

var transition_time: float = 0.75;
var id_estacion: int = 0;
var estacion: Estacion;
var id_signal_bateria: int = 0;
var altura_total: float = 0;

func _ready() -> void:
	info_mosaicos = vbox_niveles_container.get_children();
	
	GlobalSignals.connect_on_tarjeta_mosaico_clicked(_on_tarjeta_mosaico_clicked, true)
	GlobalSignals.connect_on_update_app(_on_update_app, true)

func _exit_tree() -> void:
	GlobalSignals.connect_on_tarjeta_mosaico_clicked(_on_tarjeta_mosaico_clicked, false)
	GlobalSignals.connect_on_update_app(_on_update_app, false)

func _on_tarjeta_mosaico_clicked(_id_estacion:int):
	id_estacion = _id_estacion;
	estacion = GlobalData.get_estacion(_id_estacion)
	
	var niveles: Array[Señal] = [];
	var n = 0;
	
	for info in info_mosaicos:
		info.visible = false;
	
	for _signal: Señal in estacion.signals.values():
		if _signal.tipo_signal == TIPO_SIGNAL.Tipo_Signal.Nivel:
			info_mosaicos[n].inicializar_info_mosaico_nivel(_signal);
			info_mosaicos[n].visible = true;
			niveles.append(_signal);
			n += 1;
			
	ui_graficador.init_graficador(estacion, niveles)
	altura_total = get_container_size(panel_info_mosaico)
	
	for _signal: Señal in estacion.signals.values():
		if _signal.tipo_signal == TIPO_SIGNAL.Tipo_Signal.Voltaje:
			id_signal_bateria = _signal.id_signal
			break
	
	_on_update_app()
	
	get_tween().tween_property(panel_mosaico, "size", Vector2(1080, 1780 - altura_total), transition_time)
	get_tween().tween_property(panel_info_mosaico, "position", Vector2(0, 1780 - altura_total), transition_time)
	
func _on_update_app():
	if id_estacion != 0:
		estacion = GlobalData.get_estacion(id_estacion)
		
		tr_enlace.modulate = estacion.get_color_enlace();
		lbl_id.text = str(estacion.id_estacion)
		lbl_interceptor.text = estacion.abreviacion_interceptor
		lbl_interceptor.modulate = GlobalData.get_color_interceptor(estacion.tipo_interceptor)
		tr_interceptor.modulate = GlobalData.get_color_interceptor(estacion.tipo_interceptor)
		lbl_nombre.text = estacion.nombre
		lbl_fecha.text = GlobalUtils.formatear_fecha(estacion.tiempo)
		
		var bateria: Señal = estacion.signals.get(id_signal_bateria)
		
		if bateria:
			lbl_bateria.text = bateria.get_valor_string();
	
func get_container_size(_container: Control) -> float:
	return _container.get_combined_minimum_size().y

func get_tween():
	var tween = create_tween().set_parallel(true) 
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	return tween;

func _on_button_button_down() -> void:
	id_estacion = 0;
	
	get_tween().tween_property(panel_mosaico, "size", Vector2(1080, 1790), transition_time)
	get_tween().tween_property(panel_info_mosaico, "position", Vector2(0, 1780), transition_time)
