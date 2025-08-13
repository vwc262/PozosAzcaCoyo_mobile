extends RefCounted
class_name Señal

@export var id_signal: int
@export var id_estacion: int
@export var nombre: String
@export var valor: float:
	get : return round(valor*100)/100
@export var tipo_signal: int
@export var ordinal: int
@export var indice_imagen: int
@export var dentro_limite: int
@export var dentro_rango: bool: 
	get : return self.valor != -0.9;
@export var linea: int
@export var habilitar: int
var semaforo: Semaforo


func _init(jsonData):
	self.id_signal = jsonData["idSignal"]
	self.id_estacion = jsonData["idEstacion"]
	self.nombre = jsonData["nombre"]
	self.valor = jsonData["valor"]
	self.tipo_signal = jsonData["tipoSignal"]
	self.ordinal = jsonData["ordinal"]
	self.indice_imagen = jsonData["indiceImagen"]
	self.dentro_limite = jsonData["dentroLimite"]
	self.dentro_rango = jsonData["dentroRango"] == 1
	self.linea = jsonData["linea"]
	self.habilitar = jsonData["habilitar"]

func get_color_barra_vida() -> Color:
	var color_to_return = Color(.7,.7,.7)
	var preventivo = semaforo.preventivo
	var critico = semaforo.critico
	if tipo_signal == 1:
		if dentro_rango:
			if valor > preventivo and valor <= critico:
				color_to_return = Color(.7, .7, 0) # Amarillo
			elif valor > critico:
				color_to_return = Color(.7, 0, 0) # Rojo
			else:
				color_to_return = Color(0, .7, 0) # Verde
	return color_to_return
	
func get_tipo_alerta() -> TIPO_ALERTA.ENUM_ALERTA:
	var tipo_alerta = TIPO_ALERTA.ENUM_ALERTA.NORMAL;
	if tipo_signal == 1:
		if semaforo != null:
			if valor > semaforo.normal and valor <= semaforo.preventivo:
				tipo_alerta = TIPO_ALERTA.ENUM_ALERTA.PREVENTIVO
			elif valor > semaforo.preventivo:
				tipo_alerta = TIPO_ALERTA.ENUM_ALERTA.CRITICO
			else:
				tipo_alerta = TIPO_ALERTA.ENUM_ALERTA.NORMAL
	return tipo_alerta
	
func get_unities() -> String:
	match tipo_signal:
			1:  return  "[m]"
			2:  return  "[kg/cm²]"
			3:  return  "[m³/s]"
			4:  return  "[m³]"
			6:  return  "[]"
			7:  return  "[]"
			10: return  "[V]"
			12: return  "[]"
			14: return  "[]"
			15: return  "[]"
			16: return  "[V]"
			17: return  "[A]"
			18: return  "[W]"
			19: return  "[%]"
			20: return  "[mm/h]"
			21: return  "[°C]"
			22: return  "[%]"
			23: return  "[W/m²]"
			24: return  "[km/h]"
			25: return  "[°N]"
			_: return ""
			
func get_valor_string():
	var valor_string = "---"
	valor_string = str(valor);
	
	if tipo_signal == TIPO_SIGNAL.Tipo_Signal.Nivel:
		valor_string = (str(valor) if dentro_rango else "---")
	valor_string += " " + get_unities()
	return valor_string;

func update_signal(valorUpdate:float):
	self.valor = valorUpdate
