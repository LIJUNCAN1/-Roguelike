class_name RarityGem
extends Control

var gem_color := Color.WHITE


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	queue_redraw()


func set_gem_color(color: Color) -> void:
	gem_color = color
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	var half_width := minf(size.x * 0.32, 6.0)
	var half_height := minf(size.y * 0.42, 7.0)
	var diamond := PackedVector2Array([
		center + Vector2(0.0, -half_height),
		center + Vector2(half_width, 0.0),
		center + Vector2(0.0, half_height),
		center + Vector2(-half_width, 0.0),
	])
	draw_colored_polygon(diamond, Color(gem_color, 0.28))
	draw_polyline(
		PackedVector2Array([
			diamond[0],
			diamond[1],
			diamond[2],
			diamond[3],
			diamond[0],
		]),
		gem_color,
		1.5,
		true
	)
	draw_line(diamond[0], diamond[2], Color(gem_color, 0.55), 0.7)
	draw_line(diamond[3], center, Color.WHITE, 0.7)
