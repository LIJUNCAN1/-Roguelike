class_name FramedVitalBar
extends ProgressBar

@export var fill_color := Color(0.4, 0.012, 0.025, 1.0):
	set(value):
		fill_color = value
		queue_redraw()
@export var empty_color := Color(0.008, 0.018, 0.02, 0.98)
@export var frame_texture: Texture2D
@export var pattern_texture: Texture2D

@export_group("Interior Insets")
@export var inset_left := 8.0
@export var inset_top := 5.0
@export var inset_right := 10.0
@export var inset_bottom := 5.0


func _ready() -> void:
	value_changed.connect(_on_value_changed)
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	var interior := Rect2(
		Vector2(inset_left, inset_top),
		Vector2(
			maxf(0.0, size.x - inset_left - inset_right),
			maxf(0.0, size.y - inset_top - inset_bottom)
		)
	)
	draw_rect(interior, empty_color)

	var ratio := clampf(
		(value - min_value) / maxf(max_value - min_value, 0.001),
		0.0,
		1.0
	)
	if ratio > 0.0001:
		var filled := Rect2(
			interior.position,
			Vector2(interior.size.x * ratio, interior.size.y)
		)
		draw_rect(filled, fill_color)
		_draw_pattern(filled, interior, ratio)

	if frame_texture != null:
		draw_texture_rect(
			frame_texture,
			Rect2(Vector2.ZERO, size),
			false
		)


func _draw_pattern(
	filled: Rect2,
	interior: Rect2,
	ratio: float
) -> void:
	if pattern_texture == null:
		return
	var source_size := pattern_texture.get_size()
	var source_region := Rect2(
		Vector2.ZERO,
		Vector2(source_size.x * ratio, source_size.y)
	)
	draw_texture_rect_region(
		pattern_texture,
		filled,
		source_region,
		Color(fill_color.darkened(0.28), 0.82)
	)


func _on_value_changed(_new_value: float) -> void:
	queue_redraw()
