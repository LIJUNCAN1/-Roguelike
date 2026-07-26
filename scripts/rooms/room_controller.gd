class_name RoomController
extends Node2D

signal room_completed

enum CompletionMode {
	IMMEDIATE,
	DEFEAT_ENEMIES,
	EXTERNAL,
}

@export var completion_mode: CompletionMode = CompletionMode.IMMEDIATE

var is_completed: bool = false


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
