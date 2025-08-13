extends Node

func formatear_fecha(iso_string: String) -> String:
	if iso_string == "":
		return ""

	var parts = iso_string.split("T")
	if parts.size() != 2:
		return iso_string  # formato inválido, se devuelve tal cual

	var fecha = parts[0].split("-")
	var hora = parts[1].split(":")
	if fecha.size() != 3 or hora.size() < 2:
		return iso_string

	var dia = fecha[2].pad_zeros(2)
	var mes = fecha[1].pad_zeros(2)
	var anio = fecha[0]
	var hora_str = hora[0].pad_zeros(2)
	var minuto_str = hora[1].pad_zeros(2)

	return "%s/%s/%s, %s:%s hrs." % [dia, mes, anio, hora_str, minuto_str]

func formatear_fecha_sql(datetime_dict: Dictionary) -> String:
	# Formatear cada componente con ceros a la izquierda cuando sea necesario
	var year = str(datetime_dict["year"])
	var month = "%02d" % datetime_dict["month"]
	var day = "%02d" % datetime_dict["day"]
	var hour = "%02d" % datetime_dict["hour"]
	var minute = "%02d" % datetime_dict["minute"]
	
	return "%s-%s-%s %s:%s" % [year, month, day, hour, minute]

func validar_texto_si_cambia(lblControl:Node,text:String):
	if lblControl.text != text:
		lblControl.text = text
