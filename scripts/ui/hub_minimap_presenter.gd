class_name HubMinimapPresenter
extends Control

@export_node_path("Node2D") var player_path: NodePath
@export var map_size := Vector2(1600, 1000)
@export var map_padding := 9.0

@onready var player: Node2D = get_node(player_path) as Node2D

var facility_positions: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	_collect_facilities()
	queue_redraw()


func _process(_delta: float) -> void:
	queue_redraw()


func get_player_marker_position() -> Vector2:
	return _world_to_map(player.global_position)


func get_facility_count() -> int:
	return facility_positions.size()


func _collect_facilities() -> void:
	facility_positions.clear()
	for node in get_tree().get_nodes_in_group(
		&"hub_interactables"
	):
		if node is Interactable:
			facility_positions[
				(node as Interactable).interaction_id
			] = (node as Node2D).global_position


func _draw() -> void:
	var panel_rect := Rect2(Vector2.ZERO, size)
	var inner_rect := panel_rect.grow(-map_padding)
	draw_rect(
		panel_rect,
		Color(0.004, 0.008, 0.018, 0.94),
		true
	)
	draw_rect(
		panel_rect,
		Color(0.26, 0.36, 0.45, 0.96),
		false,
		2.0
	)
	draw_rect(
		panel_rect.grow(-4.0),
		Color(0.08, 0.18, 0.22, 0.85),
		false,
		1.0
	)
	draw_rect(
		inner_rect,
		Color(0.045, 0.065, 0.075, 1),
		true
	)

	var clearing := Rect2(
		_world_to_map(Vector2(350, 330)),
		_world_to_map(Vector2(1270, 900))
		- _world_to_map(Vector2(350, 330))
	)
	draw_rect(
		clearing,
		Color(0.13, 0.16, 0.14, 0.72),
		true
	)

	for interaction_id in facility_positions:
		var marker_position := _world_to_map(
			facility_positions[interaction_id]
		)
		var marker_color := _get_facility_color(
			StringName(interaction_id)
		)
		draw_circle(marker_position, 4.0, Color(0, 0, 0, 0.9))
		draw_circle(marker_position, 2.6, marker_color)

	var player_position := get_player_marker_position()
	draw_circle(
		player_position,
		5.0,
		Color(0.2, 1, 0.9, 0.18)
	)
	draw_circle(
		player_position,
		3.0,
		Color(0.36, 0.94, 1, 1)
	)


func _world_to_map(world_position: Vector2) -> Vector2:
	var drawable_size := size - Vector2.ONE * map_padding * 2.0
	return (
		Vector2.ONE * map_padding
		+ Vector2(
			clampf(world_position.x / map_size.x, 0.0, 1.0),
			clampf(world_position.y / map_size.y, 0.0, 1.0)
		) * drawable_size
	)


func _get_facility_color(interaction_id: StringName) -> Color:
	match interaction_id:
		&"core_altar":
			return Color(0.68, 1, 0.2, 1)
		&"bloodline_shop":
			return Color(1, 0.35, 0.55, 1)
		&"forge_station":
			return Color(1, 0.52, 0.2, 1)
		&"archive_station":
			return Color(0.66, 0.42, 1, 1)
		&"rest_campfire":
			return Color(1, 0.72, 0.22, 1)
		&"companion_station":
			return Color(0.35, 1, 0.68, 1)
	return Color(0.65, 0.75, 0.78, 1)
