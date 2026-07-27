class_name RunMinimapPresenter
extends Control

@export_node_path("Node") var room_manager_path: NodePath
@export var rooms_per_view: int = 12

@onready var room_manager: RoomManager = get_node(
	room_manager_path
) as RoomManager


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	room_manager.room_changed.connect(_on_room_changed)
	resized.connect(queue_redraw)
	queue_redraw()


func _on_room_changed(_room_data: RoomData, _room_index: int) -> void:
	queue_redraw()


func _draw() -> void:
	var panel_rect := Rect2(Vector2.ZERO, size)
	draw_rect(panel_rect, Color(0.005, 0.012, 0.018, 0.94), true)
	draw_rect(panel_rect, Color(0.28, 0.34, 0.38, 0.95), false, 2.0)
	draw_rect(
		panel_rect.grow(-4.0),
		Color(0.08, 0.13, 0.16, 0.9),
		false,
		1.0
	)
	if room_manager.route_data == null:
		return

	var total := room_manager.route_data.rooms.size()
	if total <= 0:
		return
	var view_count := mini(maxi(rooms_per_view, 1), total)
	var start_index := clampi(
		room_manager.current_room_index - 4,
		0,
		maxi(total - view_count, 0)
	)
	var positions: Array[Vector2] = []
	for local_index in view_count:
		positions.append(_get_room_position(local_index))

	for local_index in range(positions.size() - 1):
		draw_line(
			positions[local_index],
			positions[local_index + 1],
			Color(0.16, 0.25, 0.29, 0.9),
			3.0
		)

	for local_index in positions.size():
		var route_index := start_index + local_index
		var is_current := route_index == room_manager.current_room_index
		var is_visited := route_index < room_manager.current_room_index
		var node_color := Color(0.055, 0.085, 0.1, 1.0)
		if is_visited:
			node_color = Color(0.18, 0.31, 0.34, 1.0)
		if is_current:
			draw_circle(
				positions[local_index],
				6.5,
				Color(0.22, 0.9, 1.0, 0.18)
			)
			node_color = Color(0.4, 0.9, 1.0, 1.0)
		var node_size := 7.0 if is_current else 5.0
		var node_rect := Rect2(
			positions[local_index] - Vector2.ONE * node_size * 0.5,
			Vector2.ONE * node_size
		)
		draw_rect(node_rect, node_color, true)
		draw_rect(
			node_rect,
			Color(0.65, 0.88, 0.92, 0.8) if is_current
			else Color(0.1, 0.16, 0.18, 1.0),
			false,
			1.0
		)


func _get_room_position(local_index: int) -> Vector2:
	var column := local_index % 4
	var row := local_index / 4
	if int(row) % 2 == 1:
		column = 3 - column
	return Vector2(11.0 + float(column) * 15.0, 13.0 + float(row) * 18.0)
