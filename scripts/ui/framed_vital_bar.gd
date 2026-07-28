class_name FramedVitalBar
extends ProgressBar

@export var fill_color := Color(0.4, 0.012, 0.025, 1.0):
	set(value):
		fill_color = value
		queue_redraw()
@export var empty_color := Color(0.008, 0.018, 0.02, 0.98)
@export var frame_texture: Texture2D
@export var fill_texture: Texture2D
@export var empty_texture: Texture2D

@export_group("Bar Shape")
@export var right_cut := 16.0
@export var content_offset_y := 0.0
@export var content_height_adjust := 0.0


func _ready() -> void:
	value_changed.connect(_on_value_changed)
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	var content_rect := Rect2(
		Vector2(0.0, content_offset_y),
		Vector2(
			size.x,
			maxf(1.0, size.y + content_height_adjust)
		)
	)
	if empty_texture != null:
		draw_texture_rect(
			empty_texture,
			content_rect,
			false
		)
	else:
		draw_colored_polygon(
			_create_bar_polygon(size.x),
			empty_color
		)

	var ratio := clampf(
		(value - min_value) / maxf(max_value - min_value, 0.001),
		0.0,
		1.0
	)
	if ratio > 0.0001:
		var fill_width := size.x * ratio
		if fill_texture != null:
			var source_size := fill_texture.get_size()
			draw_texture_rect_region(
				fill_texture,
				Rect2(
					Vector2(0.0, content_offset_y),
					Vector2(fill_width, content_rect.size.y)
				),
				Rect2(
					Vector2.ZERO,
					Vector2(
						source_size.x * ratio,
						source_size.y
					)
				),
				fill_color
			)
		else:
			draw_colored_polygon(
				_create_bar_polygon(fill_width),
				fill_color
			)

	if frame_texture != null:
		draw_texture_rect(
			frame_texture,
			Rect2(Vector2.ZERO, size),
			false
		)


func _on_value_changed(_new_value: float) -> void:
	queue_redraw()


func _create_bar_polygon(draw_width: float) -> PackedVector2Array:
	var clamped_width := clampf(draw_width, 0.0, size.x)
	var angle_start := size.x - right_cut
	if clamped_width >= size.x - 0.001:
		return PackedVector2Array([
			Vector2(0.0, 0.0),
			Vector2(angle_start, 0.0),
			Vector2(size.x, size.y * 0.5),
			Vector2(angle_start, size.y),
			Vector2(0.0, size.y),
		])
	if clamped_width > angle_start:
		var angle_progress := (
			(clamped_width - angle_start) / right_cut
		)
		var top_y := size.y * 0.5 * angle_progress
		return PackedVector2Array([
			Vector2(0.0, 0.0),
			Vector2(angle_start, 0.0),
			Vector2(clamped_width, top_y),
			Vector2(clamped_width, size.y - top_y),
			Vector2(angle_start, size.y),
			Vector2(0.0, size.y),
		])
	return PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(clamped_width, 0.0),
		Vector2(clamped_width, size.y),
		Vector2(0.0, size.y),
	])
