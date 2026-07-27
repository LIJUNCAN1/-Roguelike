class_name TechMenuButton
extends Button

@export var active_color := Color(0.2, 1.0, 0.72, 1.0)
@export var idle_color := Color(0.23, 0.34, 0.37, 0.35)


func _ready() -> void:
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	button_down.connect(queue_redraw)
	button_up.connect(queue_redraw)
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	var active := is_hovered() or button_pressed
	var width := size.x
	var height := size.y
	draw_line(
		Vector2(0.0, height - 0.5),
		Vector2(width, height - 0.5),
		idle_color,
		0.45,
		true
	)
	if not active:
		return

	for offset_value in [2.0, 1.0]:
		var offset := float(offset_value)
		_draw_fading_line(
			offset,
			Color(active_color, 0.13),
			0.45
		)
		_draw_fading_line(
			height - offset,
			Color(active_color, 0.13),
			0.45
		)

	_draw_fading_line(0.5, active_color, 0.65)
	_draw_fading_line(height - 0.5, active_color, 0.65)
	draw_line(
		Vector2(0.5, 0),
		Vector2(0.5, height),
		active_color,
		0.65,
		true
	)

	var center_y := height * 0.5
	var diamond := PackedVector2Array([
		Vector2(-3.0, center_y),
		Vector2(0.5, center_y - 5.0),
		Vector2(4.0, center_y),
		Vector2(0.5, center_y + 5.0),
	])
	draw_colored_polygon(diamond, Color(active_color, 0.82))


func _draw_fading_line(
	y_position: float,
	color: Color,
	line_width: float
) -> void:
	var segment_count := 32
	var segment_width := size.x / float(segment_count)
	for index in segment_count:
		var progress := float(index) / float(segment_count - 1)
		var alpha := pow(1.0 - progress, 1.55) * color.a
		var segment_color := Color(color, alpha)
		draw_line(
			Vector2(segment_width * index, y_position),
			Vector2(segment_width * (index + 1), y_position),
			segment_color,
			line_width,
			true
		)
