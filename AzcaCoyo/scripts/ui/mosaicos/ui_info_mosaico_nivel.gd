extends PanelContainer

var nivel: Señal;

@onready var nombre_signal: Label = %Nombre_signal
@onready var ui_progressbar: Control = %UiProgressbar
@onready var color_signal = %ColorSignal

func inicializar_info_mosaico_nivel(_nivel: Señal):
	nivel = _nivel
	nombre_signal.text = nivel.nombre;
	ui_progressbar.set_data_nivel(nivel);
	color_signal.modulate = GlobalData.get_color_signal(nivel.ordinal)
