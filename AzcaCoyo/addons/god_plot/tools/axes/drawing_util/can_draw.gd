class_name CanDraw
	
func _init() -> void:
	push_error("Cannot instantiate abstract class: " + get_script().get_global_name())

func draw_on(canvas_item : CanvasItem, color: Color):
	push_error("Method draw_on() not defined for object " + get_script().get_global_name())
