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
	var cut := 13.0
	var outer := PackedVector2Array([
		Vector2(cut, 0.75),
		Vector2(width - cut, 0.75),
		Vector2(width - 0.75, cut),
		Vector2(width - 0.75, height - cut),
		Vector2(width - cut, height - 0.75),
		Vector2(cut, height - 0.75),
		Vector2(0.75, height - cut),
		Vector2(0.75, cut),
		Vector2(cut, 0.75),
	])
	draw_polyline(outer, frame_color, 1.05, true)

	var inner_cut := 8.0
	var inner_margin := 7.0
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
	draw_polyline(inner, faint_color, 0.65, true)

	var title_y := 48.0
	draw_line(
		Vector2(18.0, title_y),
		Vector2(width * 0.36, title_y),
		faint_color,
		0.65,
		true
	)
	draw_line(
		Vector2(width * 0.64, title_y),
		Vector2(width - 18.0, title_y),
		faint_color,
		0.65,
		true
	)
