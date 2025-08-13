@tool
class_name DrawingAnchor extends Control

var drawing_objects : Array[CanDraw] = []

func add_drawing_object(drawing_object : CanDraw, color: Color):
	if !drawing_objects.has(drawing_object):
		draw.connect(drawing_object.draw_on.bind(self, color))
		drawing_objects.append(drawing_object)
		
