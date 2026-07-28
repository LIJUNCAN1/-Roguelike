class_name TechSettingsPanel
extends PanelContainer

@export var frame_color := Color(0.08, 0.86, 0.84, 0.9)
@export var faint_color := Color(0.08, 0.58, 0.62, 0.28)


func _ready() -> void:
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	var width := size.x
	var height := size.y
	var cut := 18.0
	var outer := PackedVector2Array([
		Vector2(cut, 1.5),
		Vector2(width - cut, 1.5),
		Vector2(width - 1.5, cut),
		Vector2(width - 1.5, height - cut),
		Vector2(width - cut, height - 1.5),
		Vector2(cut, height - 1.5),
		Vector2(1.5, height - cut),
		Vector2(1.5, cut),
		Vector2(cut, 1.5),
	])
	draw_polyline(outer, frame_color, 2.1, true)

	var inner_cut := 12.0
	var inner_margin := 10.0
	var inner := PackedVector2Array([
		Vector2(inner_margin + inner_cut, inner_margin),
		Vector2(width - inner_margin - inner_cut, inner_margin),
		Vector2(width - inner_margin, inner_margin + inner_cut),
		Vector2(width - inner_margin, height - inner_margin - inner_cut),
		Vector2(width - inner_margin - inner_cut, height - inner_margin),
		Vector2(inner_margin + inner_cut, height - inner_margin),
		Vector2(inner_margin, height - inner_margin - inner_cut),
		Vector2(inner_margin, inner_margin + inner_cut),
	])
	draw_polyline(inner, faint_color, 1.3, true)

	var title_y := 58.0
	draw_line(
		Vector2(26.0, title_y),
		Vector2(width * 0.36, title_y),
		faint_color,
		1.3,
		true
	)
	draw_line(
		Vector2(width * 0.64, title_y),
		Vector2(width - 26.0, title_y),
		faint_color,
		1.3,
		true
	)
