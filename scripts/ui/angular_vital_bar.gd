class_name AngularVitalBar
extends ProgressBar

@export var frame_color := Color(0.42, 0.43, 0.42, 1.0)
@export var frame_highlight := Color(0.78, 0.78, 0.7, 0.9)
@export var inner_background_color := Color(0.01, 0.025, 0.028, 0.98)
@export var pattern_alpha := 0.22
@export var right_cut := 9.0
@export var frame_texture: Texture2D
@export var pattern_texture: Texture2D


func _ready() -> void:
	value_changed.connect(_on_value_changed)
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	var width := size.x
	var height := size.y
	if width <= right_cut * 2.0 or height <= 8.0:
		return

	var outer := PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(width - right_cut, 0.0),
		Vector2(width, height * 0.5),
		Vector2(width - right_cut, height),
		Vector2(0.0, height),
	])
	draw_colored_polygon(outer, Color(0.015, 0.016, 0.015, 1.0))
	draw_polyline(
		PackedVector2Array([
			outer[0],
			outer[1],
			outer[2],
			outer[3],
			outer[4],
			outer[0],
		]),
		frame_color,
		2.0,
		true
	)
	draw_line(
		Vector2(3.0, 2.0),
		Vector2(width - right_cut - 1.0, 2.0),
		frame_highlight,
		1.0,
		true
	)

	var inset := 4.0
	var inner_right := width - right_cut - inset
	var inner_tip := width - inset
	var inner := PackedVector2Array([
		Vector2(inset, inset),
		Vector2(inner_right, inset),
		Vector2(inner_tip, height * 0.5),
		Vector2(inner_right, height - inset),
		Vector2(inset, height - inset),
	])
	draw_colored_polygon(inner, inner_background_color)

	var ratio := clampf(
		(value - min_value) / maxf(max_value - min_value, 0.001),
		0.0,
		1.0
	)
	if ratio <= 0.0001:
		_draw_frame_texture()
		return

	var fill_style := get_theme_stylebox("fill") as StyleBoxFlat
	var fill_color := (
		fill_style.bg_color
		if fill_style != null
		else Color(0.7, 0.03, 0.04, 1.0)
	)
	var fill_end := lerpf(inset, inner_tip, ratio)
	var fill_points: PackedVector2Array
	if ratio >= 0.995:
		fill_points = inner
	else:
		fill_points = PackedVector2Array([
			Vector2(inset, inset),
			Vector2(fill_end, inset),
			Vector2(fill_end, height - inset),
			Vector2(inset, height - inset),
		])
	draw_colored_polygon(fill_points, fill_color)
	_draw_pattern(fill_end, height, fill_color)
	draw_line(
		Vector2(inset + 1.0, inset + 1.0),
		Vector2(maxf(inset + 1.0, fill_end - 1.0), inset + 1.0),
		Color(fill_color.lightened(0.45), 0.82),
		1.0,
		true
	)
	_draw_frame_texture()


func _draw_pattern(
	fill_end: float,
	height: float,
	fill_color: Color
) -> void:
	var top := 6.0
	var bottom := height - 6.0
	if pattern_texture != null:
		draw_texture_rect(
			pattern_texture,
			Rect2(
				Vector2(4.0, 5.0),
				Vector2(
					maxf(0.0, fill_end - 4.0),
					maxf(1.0, height - 10.0)
				)
			),
			false,
			Color(fill_color.lightened(0.42), 0.72)
		)
		return
	var pattern_color := Color(
		fill_color.darkened(0.35),
		pattern_alpha
	)
	var x := 8.0
	while x + 13.0 < fill_end:
		draw_colored_polygon(
			PackedVector2Array([
				Vector2(x, top),
				Vector2(x + 7.0, bottom),
				Vector2(x + 14.0, top),
			]),
			pattern_color
		)
		x += 16.0


func _on_value_changed(_new_value: float) -> void:
	queue_redraw()


func _draw_frame_texture() -> void:
	if frame_texture == null:
		return
	draw_texture_rect(
		frame_texture,
		Rect2(Vector2.ZERO, size),
		false
	)
