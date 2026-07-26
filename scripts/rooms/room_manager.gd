class_name RoomManager
extends Node

signal room_changed(room_data: RoomData, room_index: int)
signal run_completed

@export var route_data: RunRouteData
@export_node_path("Node2D") var room_container_path: NodePath
@export_node_path("Node2D") var player_path: NodePath
@export_node_path("Node2D") var projectile_container_path: NodePath
@export_node_path("Node2D") var effects_container_path: NodePath
@export_node_path("Label") var room_status_label_path: NodePath
@export_node_path("Label") var room_hint_label_path: NodePath

@onready var room_container: Node2D = get_node(
	room_container_path
) as Node2D
@onready var player: Node2D = get_node(player_path) as Node2D
@onready var projectile_container: Node2D = get_node(
	projectile_container_path
) as Node2D
@onready var effects_container: Node2D = get_node(
	effects_container_path
) as Node2D
@onready var room_status_label: Label = get_node(
	room_status_label_path
) as Label
@onready var room_hint_label: Label = get_node(
	room_hint_label_path
) as Label

var current_room_index: int = -1
var current_room: RoomController
var is_run_complete: bool = false


func _ready() -> void:
	if route_data == null or route_data.rooms.is_empty():
		push_error("RoomManager requires a non-empty RunRouteData.")
		return
	enter_room(0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("next_room"):
		advance_room()
		get_viewport().set_input_as_handled()


func enter_room(room_index: int) -> bool:
	if (
		route_data == null
		or room_index < 0
		or room_index >= route_data.rooms.size()
	):
		return false

	var room_data := route_data.rooms[room_index]
	if room_data == null or room_data.room_scene == null:
		return false

	_clear_container(room_container)
	_clear_container(projectile_container)
	_clear_container(effects_container)

	current_room = room_data.room_scene.instantiate() as RoomController
	room_container.add_child(current_room)
	current_room.room_completed.connect(_update_room_hint)
	current_room_index = room_index
	is_run_complete = false
	player.global_position = Vector2(320, 180)
	_configure_room_enemies()
	_update_room_status()
	_update_room_hint()
	room_changed.emit(room_data, current_room_index)
	return true


func advance_room() -> bool:
	if current_room == null or not current_room.is_completed:
		room_hint_label.text = "房间尚未完成"
		room_hint_label.modulate = Color(1.0, 0.35, 0.25, 1.0)
		return false

	var next_index := current_room_index + 1
	if next_index >= route_data.rooms.size():
		is_run_complete = true
		room_hint_label.text = "固定路线完成"
		room_hint_label.modulate = Color(0.45, 1.0, 0.68, 1.0)
		run_completed.emit()
		return false

	return enter_room(next_index)


func get_current_room_data() -> RoomData:
	if (
		route_data == null
		or current_room_index < 0
		or current_room_index >= route_data.rooms.size()
	):
		return null
	return route_data.rooms[current_room_index]


func _configure_room_enemies() -> void:
	for node in get_tree().get_nodes_in_group(&"room_enemies"):
		if not current_room.is_ancestor_of(node):
			continue

		var enemy := node as EnemyController
		if enemy == null:
			continue
		enemy.set_target(player)
		enemy.set_feedback_container(effects_container)


func _update_room_status() -> void:
	var room_data := get_current_room_data()
	if room_data == null:
		return
	room_status_label.text = "房间 %d/%d：%s" % [
		current_room_index + 1,
		route_data.rooms.size(),
		room_data.display_name,
	]


func _update_room_hint() -> void:
	if current_room == null:
		return

	if current_room.is_completed:
		room_hint_label.text = "房间完成 · 按 N 前进"
		room_hint_label.modulate = Color(0.45, 1.0, 0.68, 1.0)
	else:
		room_hint_label.text = "击败房间内全部敌人"
		room_hint_label.modulate = Color(1.0, 0.72, 0.25, 1.0)


func _clear_container(container: Node) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
