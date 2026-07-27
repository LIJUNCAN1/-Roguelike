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
		1.0,
		true
	)
	if not active:
		return

	var glow := Color(active_color, 0.22)
	for offset in [3.0, 2.0, 1.0]:
		draw_line(
			Vector2(0.0, offset),
			Vector2(width, offset),
			glow,
			1.0,
			true
		)
		draw_line(
			Vector2(0.0, height - offset),
			Vector2(width, height - offset),
			glow,
			1.0,
			true
		)

	draw_line(Vector2(0, 0.5), Vector2(width, 0.5), active_color, 1.1, true)
	draw_line(
		Vector2(0, height - 0.5),
		Vector2(width, height - 0.5),
		active_color,
		1.1,
		true
	)
	draw_line(Vector2(0.5, 0), Vector2(0.5, height), active_color, 1.1, true)

	var center_y := height * 0.5
	var diamond := PackedVector2Array([
		Vector2(-3.0, center_y),
		Vector2(0.5, center_y - 5.0),
		Vector2(4.0, center_y),
		Vector2(0.5, center_y + 5.0),
	])
	draw_colored_polygon(diamond, Color(active_color, 0.82))
