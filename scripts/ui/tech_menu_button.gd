class_name TechMenuButton
extends Button

@export var active_color := Color(0.2, 1.0, 0.72, 1.0)
@export var idle_color := Color(0.23, 0.34, 0.37, 0.35)
@export var idle_text_color := Color(0.86, 0.87, 0.89, 1.0)
@export var active_text_color := Color(0.96, 1.0, 0.97, 1.0)

var hover_amount: float = 0.0:
	set(value):
		hover_amount = clampf(value, 0.0, 1.0)
		_update_text_color()
		queue_redraw()
var hover_tween: Tween


func _ready() -> void:
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	mouse_entered.connect(_animate_hover.bind(true))
	mouse_exited.connect(_animate_hover.bind(false))
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	button_down.connect(queue_redraw)
	button_up.connect(queue_redraw)
	resized.connect(queue_redraw)
	_update_text_color()
	queue_redraw()


func _draw() -> void:
	var intensity := maxf(
		hover_amount,
		1.0 if button_pressed else 0.0
	)
	var width := size.x
	var height := size.y
	draw_line(
		Vector2(0.0, height - 1.0),
		Vector2(width, height - 1.0),
		idle_color,
		0.9,
		true
	)
	if intensity <= 0.001:
		return

	for offset_value in [4.0, 2.0]:
		var offset := float(offset_value)
		_draw_fading_line(
			offset,
			Color(active_color, 0.13 * intensity),
			0.9
		)
		_draw_fading_line(
			height - offset,
			Color(active_color, 0.13 * intensity),
			0.9
		)

	_draw_fading_line(
		1.0,
		Color(active_color, active_color.a * intensity),
		1.3
	)
	_draw_fading_line(
		height - 1.0,
		Color(active_color, active_color.a * intensity),
		1.3
	)
	draw_line(
		Vector2(1.0, 0),
		Vector2(1.0, height),
		Color(active_color, active_color.a * intensity),
		1.3,
		true
	)

	var center_y := height * 0.5
	var diamond := PackedVector2Array([
		Vector2(-6.0, center_y),
		Vector2(1.0, center_y - 10.0),
		Vector2(8.0, center_y),
		Vector2(1.0, center_y + 10.0),
	])
	draw_colored_polygon(
		diamond,
		Color(active_color, 0.82 * intensity)
	)


func _animate_hover(is_hovered_now: bool) -> void:
	if hover_tween != null:
		hover_tween.kill()
	hover_tween = create_tween()
	var duration := 0.18 if is_hovered_now else 0.28
	hover_tween.tween_property(
		self,
		"hover_amount",
		1.0 if is_hovered_now else 0.0,
		duration
	).set_trans(Tween.TRANS_QUAD).set_ease(
		Tween.EASE_OUT if is_hovered_now else Tween.EASE_IN_OUT
	)


func _update_text_color() -> void:
	var text_color := idle_text_color.lerp(
		active_text_color,
		hover_amount
	)
	for color_name in [
		"font_color",
		"font_hover_color",
		"font_focus_color",
		"font_pressed_color",
	]:
		add_theme_color_override(color_name, text_color)


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
