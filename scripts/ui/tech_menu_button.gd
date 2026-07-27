class_name TechMenuButton
extends Button

@export var active_color := Color(0.2, 1.0, 0.72, 1.0)
@export var idle_color := Color(0.48, 0.61, 0.72, 0.95)


func _ready() -> void:
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	button_down.connect(queue_redraw)
	button_up.connect(queue_redraw)
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	var active := has_focus() or is_hovered() or button_pressed
	var color := active_color if active else idle_color
	var width := size.x
	var height := size.y
	var chamfer := 5.0

	var outer := PackedVector2Array([
		Vector2(chamfer, 0.5),
		Vector2(width - chamfer, 0.5),
		Vector2(width - 0.5, chamfer),
		Vector2(width - 0.5, height - chamfer),
		Vector2(width - chamfer, height - 0.5),
		Vector2(chamfer, height - 0.5),
		Vector2(0.5, height - chamfer),
		Vector2(0.5, chamfer),
		Vector2(chamfer, 0.5),
	])
	draw_polyline(outer, color, 1.15, true)

	var inner_color := Color(color, 0.42 if active else 0.3)
	var inner := PackedVector2Array([
		Vector2(chamfer + 2.0, 3.0),
		Vector2(width - chamfer - 2.0, 3.0),
		Vector2(width - 3.0, chamfer + 2.0),
		Vector2(width - 3.0, height - chamfer - 2.0),
		Vector2(width - chamfer - 2.0, height - 3.0),
		Vector2(chamfer + 2.0, height - 3.0),
		Vector2(3.0, height - chamfer - 2.0),
		Vector2(3.0, chamfer + 2.0),
	])
	draw_polyline(inner, inner_color, 1.0, true)
	_draw_corner_ticks(color)

	if active:
		_draw_selection_arrows(color)


func _draw_corner_ticks(color: Color) -> void:
	var width := size.x
	var height := size.y
	var tick_color := Color(color, 0.78)
	var segments := [
		[Vector2(6, 0), Vector2(13, 0)],
		[Vector2(0, 6), Vector2(0, 12)],
		[Vector2(width - 13, 0), Vector2(width - 6, 0)],
		[Vector2(width, 6), Vector2(width, 12)],
		[Vector2(6, height), Vector2(13, height)],
		[Vector2(0, height - 12), Vector2(0, height - 6)],
		[Vector2(width - 13, height), Vector2(width - 6, height)],
		[Vector2(width, height - 12), Vector2(width, height - 6)],
	]
	for segment in segments:
		draw_line(segment[0], segment[1], tick_color, 1.4, true)


func _draw_selection_arrows(color: Color) -> void:
	var center_y := size.y * 0.5
	var left_triangle := PackedVector2Array([
		Vector2(10, center_y - 6),
		Vector2(17, center_y),
		Vector2(10, center_y + 6),
	])
	var right_triangle := PackedVector2Array([
		Vector2(size.x - 10, center_y - 6),
		Vector2(size.x - 17, center_y),
		Vector2(size.x - 10, center_y + 6),
	])
	draw_colored_polygon(left_triangle, Color(color, 0.9))
	draw_colored_polygon(right_triangle, Color(color, 0.9))

	for offset_value in [0.0, 4.0, 8.0]:
		var offset := float(offset_value)
		var left_x: float = -7.0 - offset
		var right_x: float = size.x + 7.0 + offset
		draw_polyline(
			PackedVector2Array([
				Vector2(left_x, center_y - 4),
				Vector2(left_x + 4, center_y),
				Vector2(left_x, center_y + 4),
			]),
			Color(color, 0.78),
			1.0,
			true
		)
		draw_polyline(
			PackedVector2Array([
				Vector2(right_x, center_y - 4),
				Vector2(right_x - 4, center_y),
				Vector2(right_x, center_y + 4),
			]),
			Color(color, 0.78),
			1.0,
			true
		)
