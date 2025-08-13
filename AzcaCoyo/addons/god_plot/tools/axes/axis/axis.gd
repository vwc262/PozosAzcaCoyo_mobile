class_name Axis extends CanDraw

var axis_ticks := AxisTicks.new()
var axis_labels := AxisLabels.new()

var is_vertical : bool = false: 
	set(value):
		is_vertical = value
		direction = Vector2.UP if is_vertical else Vector2.RIGHT
		out_direction = Vector2.LEFT if is_vertical else Vector2.DOWN

var min_value : float = 0
var max_value : float = 10

var length : float = 500.0:
	set(value):
		length = max(0, value)
var color : Color = Color.WHITE
var offset : Vector2 = Vector2.ZERO
var direction : Vector2 = Vector2.RIGHT
var out_direction : Vector2 = Vector2.DOWN
var decimal_places : int = 2
var thickness : float = 3.0

static func new_x_axis() -> Axis:
	return Axis.new()

static func new_y_axis() -> Axis:
	var axis = Axis.new()
	axis.is_vertical = true
	return axis

func _init() -> void:
	axis_ticks.set_axis(self)
	axis_labels.set_axis(self)

func draw_on(canvas_item : CanvasItem, color: Color) -> void:
	_draw_axis_on(canvas_item)
	axis_ticks.draw_on(canvas_item, color)
	axis_labels.draw_on(canvas_item, color)

func _draw_axis_on(canvas_item : CanvasItem):	
	canvas_item.draw_circle(offset, thickness/2, color)
	canvas_item.draw_line(offset, offset + length * direction, color, thickness)
	canvas_item.draw_circle(offset + length * direction, thickness/2, color)
	
func get_range() -> float:
	return max_value - min_value

func get_zero_position_along_axis_clipped() -> float:
	if min_value >= 0:
		return 0.0
	if max_value <= 0:
		return length
	else:
		return (0.0 - min_value) / get_range() * length

func get_label_values_at_ticks() -> Array[float]:
	var tick_values : Array[float] = []
	var range := get_range()
	for tick_position in get_tick_positions_along_axis():
		var value = min_value + tick_position / length * range
		tick_values.append(value)
	return tick_values

func get_tick_positions_along_axis() -> Array[float]:
	return axis_ticks.positions_along_axis

func get_tick_length() -> float:
	return axis_ticks.get_length()

func get_tick_interval() -> float:
	return axis_ticks.interval

func get_pixel_distance_from_minimum(distance_from_minimum : float) -> float:
	return remap(distance_from_minimum, 0, get_range(), 0, length)

func set_font_and_size(font : Font, size : float):
	axis_labels.font = font
	axis_labels.font_size = size

func set_num_ticks(num : int):
	axis_ticks.intended_num_ticks = num

func set_label_visibility(is_visible : bool):
	axis_labels.visible = is_visible
