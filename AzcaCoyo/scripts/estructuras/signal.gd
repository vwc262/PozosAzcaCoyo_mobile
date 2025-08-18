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
	
func get_color_bomba_string():
	return Color.from_string("#808080", "gray") if valor == 0 else Color.from_string("#00ff00", "green") if valor == 1 else Color.from_string("#ff0000", "red") if valor == 2 else Color.from_string("#0000ff", "blue")

func get_color_bomba_vec4():
	return Vector4(0.2,0.2,0.2,1) if valor == 0 else Vector4(0,0.2,0,1) if valor == 1 else Vector4(0.35,0,0,1) if valor == 2 else Vector4(0,0,0.2,1)
