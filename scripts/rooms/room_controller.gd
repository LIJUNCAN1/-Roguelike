class_name RoomController
extends Node2D

signal room_completed

enum CompletionMode {
	IMMEDIATE,
	DEFEAT_ENEMIES,
	EXTERNAL,
}

@export var completion_mode: CompletionMode = CompletionMode.IMMEDIATE
@export var room_bounds: Rect2 = Rect2(0.0, 0.0, 640.0, 360.0)
@export var player_spawn_position: Vector2 = Vector2(320.0, 180.0)

var is_completed: bool = false
var current_region: RegionData


func _ready() -> void:
	if completion_mode == CompletionMode.IMMEDIATE:
		call_deferred("_mark_completed")


func _process(_delta: float) -> void:
	if (
		not is_completed
		and completion_mode == CompletionMode.DEFEAT_ENEMIES
		and _get_alive_enemy_count() == 0
	):
		_mark_completed()


func _mark_completed() -> void:
	if is_completed:
		return
	is_completed = true
	room_completed.emit()


func configure_player(_player: Node2D) -> void:
	pass


func configure_run(player: Node2D, _run_seed: int) -> void:
	configure_player(player)


func get_room_bounds() -> Rect2:
	return room_bounds


func get_player_spawn_position() -> Vector2:
	return player_spawn_position


func apply_region(region: RegionData) -> void:
	current_region = region
	if region == null:
		return

	var room_shell := get_node_or_null("RoomShell") as Node2D
	if room_shell == null:
		return
	room_shell.modulate = Color.WHITE

	_set_polygon_color(room_shell, "Void", region.void_color)
	_set_polygon_color(room_shell, "ArenaFloor", region.floor_color)
	_set_polygon_color(room_shell, "FloorPatchA", region.patch_color)
	_set_polygon_color(room_shell, "FloorPatchB", region.patch_color)
	for wall_name in ["Top", "Bottom", "Left", "Right"]:
		_set_polygon_color(
			room_shell,
			"Walls/%s/Visual" % wall_name,
			region.wall_color
		)

	var decoration_anchor := room_shell.get_node_or_null(
		"RegionDecorations"
	) as Node2D
	if decoration_anchor == null:
		return
	for child in decoration_anchor.get_children():
		child.queue_free()
	if (
		region.visual_data != null
		and region.visual_data.source_atlas != null
		and region.visual_data.sample_floor_region.size.x > 0.0
	):
		var tile_backdrop := RegionTileBackdrop.new()
		tile_backdrop.name = "GeneratedTileBackdrop"
		decoration_anchor.add_child(tile_backdrop)
		tile_backdrop.setup(region.visual_data)
	var replacement_scene: PackedScene
	if region.visual_data != null:
		replacement_scene = region.visual_data.environment_scene
	if replacement_scene != null:
		decoration_anchor.add_child(replacement_scene.instantiate())
	elif region.decoration_scene != null:
		decoration_anchor.add_child(
			region.decoration_scene.instantiate()
		)


func get_incomplete_hint() -> String:
	return "击败房间内全部敌人"


func _get_alive_enemy_count() -> int:
	var enemy_count := 0
	for node in get_tree().get_nodes_in_group(&"room_enemies"):
		if not is_ancestor_of(node) or node.is_queued_for_deletion():
			continue

		var health := node.get_node_or_null(
			"HealthComponent"
		) as HealthComponent
		if health != null and health.is_dead:
			continue

		enemy_count += 1
	return enemy_count


func _set_polygon_color(
	root: Node,
	path: NodePath,
	color: Color
) -> void:
	var polygon := root.get_node_or_null(path) as Polygon2D
	if polygon != null:
		polygon.color = color
