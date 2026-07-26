class_name RoomManager
extends Node

signal room_changed(room_data: RoomData, room_index: int)
signal run_completed

@export var route_data: RunRouteData
@export var random_route_data: RandomRouteData
@export var route_exit_selector_scene: PackedScene
@export var route_seed: int = 0
@export_node_path("Node2D") var room_container_path: NodePath
@export_node_path("Node2D") var player_path: NodePath
@export_node_path("Node2D") var projectile_container_path: NodePath
@export_node_path("Node2D") var effects_container_path: NodePath
@export_node_path("Label") var room_status_label_path: NodePath
@export_node_path("Label") var region_status_label_path: NodePath
@export_node_path("Label") var room_hint_label_path: NodePath
@export_node_path("Label") var route_preview_label_path: NodePath

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
@onready var region_status_label: Label = get_node_or_null(
	region_status_label_path
) as Label
@onready var room_hint_label: Label = get_node(
	room_hint_label_path
) as Label
@onready var route_preview_label: Label = get_node_or_null(
	route_preview_label_path
) as Label

var current_room_index: int = -1
var current_room: RoomController
var is_run_complete: bool = false
var current_route_seed: int = 0
var pending_room_choices: Array[RoomData] = []
var pending_room_index: int = -1
var chosen_route_layers: Dictionary = {}
var current_route_exit_selector: RouteExitSelector


func _ready() -> void:
	_generate_route_if_configured()
	if route_data == null or route_data.rooms.is_empty():
		push_error("RoomManager requires a non-empty RunRouteData.")
		return
	_update_route_preview()
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
	current_route_exit_selector = null
	pending_room_choices.clear()
	pending_room_index = -1

	current_room = room_data.room_scene.instantiate() as RoomController
	room_container.add_child(current_room)
	if (
		current_room is GeneRewardRoom
		and room_data.gene_reward_pool != null
	):
		(current_room as GeneRewardRoom).reward_pool = (
			room_data.gene_reward_pool
		)
	current_room.room_completed.connect(_on_current_room_completed)
	current_room_index = room_index
	chosen_route_layers[room_index] = true
	is_run_complete = false
	player.global_position = Vector2(320, 180)
	current_room.apply_region(room_data.region)
	current_room.configure_run(player, current_route_seed)
	_configure_room_enemies()
	_update_room_status()
	_update_room_hint()
	_update_route_preview()
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
		room_hint_label.text = "本次随机路线完成"
		room_hint_label.modulate = Color(0.45, 1.0, 0.68, 1.0)
		run_completed.emit()
		return false

	if _prepare_next_room_choices():
		return false
	return enter_room(next_index)


func choose_room_branch(choice_index: int) -> bool:
	if (
		pending_room_index < 0
		or choice_index < 0
		or choice_index >= pending_room_choices.size()
	):
		return false

	var selected_room := pending_room_choices[choice_index]
	route_data.rooms[pending_room_index] = selected_room
	var selected_index := pending_room_index
	pending_room_choices.clear()
	pending_room_index = -1
	current_route_exit_selector = null
	_update_route_preview()
	return enter_room(selected_index)


func restart_run(new_seed: int = 0) -> bool:
	route_seed = new_seed
	current_room_index = -1
	current_room = null
	is_run_complete = false
	pending_room_choices.clear()
	pending_room_index = -1
	current_route_exit_selector = null
	_generate_route_if_configured()
	if route_data == null or route_data.rooms.is_empty():
		return false
	return enter_room(0)


func get_current_room_data() -> RoomData:
	if (
		route_data == null
		or current_room_index < 0
		or current_room_index >= route_data.rooms.size()
	):
		return null
	return route_data.rooms[current_room_index]


func get_current_chapter() -> ChapterData:
	var chapter_route := random_route_data as ChapterRouteData
	if chapter_route == null:
		return null
	return chapter_route.get_chapter_for_room(current_room_index)


func get_current_chapter_index() -> int:
	var chapter_route := random_route_data as ChapterRouteData
	if chapter_route == null:
		return -1
	return chapter_route.get_chapter_index_for_room(current_room_index)


func get_route_room_ids() -> Array[StringName]:
	var room_ids: Array[StringName] = []
	if route_data == null:
		return room_ids
	for room in route_data.rooms:
		if room != null:
			room_ids.append(room.id)
	return room_ids


func _configure_room_enemies() -> void:
	for node in get_tree().get_nodes_in_group(&"room_enemies"):
		if not current_room.is_ancestor_of(node):
			continue

		var enemy := node as EnemyController
		if enemy == null:
			continue
		enemy.set_target(player)
		enemy.set_feedback_container(effects_container)
		enemy.set_projectile_container(projectile_container)
		enemy.apply_difficulty(1.0 + float(current_room_index) * 0.08)


func _update_room_status() -> void:
	var room_data := get_current_room_data()
	if room_data == null:
		return
	room_status_label.text = "房间 %d/%d：%s" % [
		current_room_index + 1,
		route_data.rooms.size(),
		room_data.display_name,
	]
	var chapter := get_current_chapter()
	var chapter_index := get_current_chapter_index()
	if chapter != null and chapter_index >= 0:
		room_status_label.text = "章节 %d/%d · 房间 %d/%d：%s" % [
			chapter_index + 1,
			(random_route_data as ChapterRouteData).chapters.size(),
			current_room_index + 1,
			route_data.rooms.size(),
			room_data.display_name,
		]
	if region_status_label == null:
		return
	if room_data.region == null:
		region_status_label.text = "区域：未指定"
		region_status_label.modulate = Color.WHITE
		return
	region_status_label.text = "区域：%s" % room_data.region.display_name
	region_status_label.modulate = room_data.region.accent_color


func _generate_route_if_configured() -> void:
	if random_route_data == null:
		return

	current_route_seed = route_seed
	if current_route_seed == 0:
		var seed_rng := RandomNumberGenerator.new()
		seed_rng.randomize()
		current_route_seed = seed_rng.randi()
	route_data = random_route_data.generate_route(current_route_seed)
	chosen_route_layers.clear()


func _update_route_preview() -> void:
	if route_preview_label == null or route_data == null:
		return

	var room_names := PackedStringArray()
	for index in route_data.rooms.size():
		if (
			random_route_data != null
			and index < random_route_data.room_pools.size()
			and not chosen_route_layers.has(index)
		):
			var candidates := random_route_data.room_pools[
				index
			].get_valid_rooms()
			if candidates.size() > 1:
				var candidate_names := PackedStringArray()
				for candidate in candidates:
					candidate_names.append(candidate.display_name)
				room_names.append("[%s]" % " / ".join(candidate_names))
				continue

		var room := route_data.rooms[index]
		if room != null:
			room_names.append(room.display_name)
	route_preview_label.text = "路线：%s  ·  种子 %d" % [
		" → ".join(room_names),
		current_route_seed,
	]


func _on_current_room_completed() -> void:
	_update_room_hint()
	call_deferred("_prepare_next_room_choices")


func _prepare_next_room_choices() -> bool:
	if not pending_room_choices.is_empty():
		room_hint_label.text = "走进左侧或右侧入口选择路线"
		room_hint_label.modulate = Color(0.4, 0.75, 1.0, 1.0)
		return true
	if random_route_data == null:
		return false

	var next_index := current_room_index + 1
	if next_index < 0 or next_index >= route_data.rooms.size():
		return false
	var choices := random_route_data.get_room_choices(
		next_index,
		current_route_seed
	)
	if choices.size() <= 1:
		return false

	pending_room_choices.assign(choices)
	pending_room_index = next_index
	if route_exit_selector_scene == null:
		push_error("RoomManager requires a route exit selector scene.")
		pending_room_choices.clear()
		pending_room_index = -1
		return false

	current_route_exit_selector = (
		route_exit_selector_scene.instantiate() as RouteExitSelector
	)
	current_room.add_child(current_route_exit_selector)
	current_route_exit_selector.exit_entered.connect(
		choose_room_branch
	)
	current_route_exit_selector.configure(
		pending_room_choices,
		player
	)
	room_hint_label.text = "走进左侧或右侧入口选择路线"
	room_hint_label.modulate = Color(0.4, 0.75, 1.0, 1.0)
	return true


func _update_room_hint() -> void:
	if current_room == null:
		return

	if current_room.is_completed:
		room_hint_label.text = "房间完成 · 按 N 前进"
		room_hint_label.modulate = Color(0.45, 1.0, 0.68, 1.0)
	else:
		room_hint_label.text = current_room.get_incomplete_hint()
		room_hint_label.modulate = Color(1.0, 0.72, 0.25, 1.0)


func _clear_container(container: Node) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
