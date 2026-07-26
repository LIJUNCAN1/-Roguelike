class_name CompanionManager
extends Node

signal companion_changed(companion: CompanionData)

@export var default_companion: CompanionData

var current_companion: CompanionData
var active_companion: CompanionController


func _ready() -> void:
	call_deferred("reset_to_default")


func select_companion(companion: CompanionData) -> bool:
	if companion == null or companion.id.is_empty():
		return false

	_clear_active_companion()
	current_companion = companion
	if companion.companion_scene != null:
		if not _spawn_companion(companion):
			current_companion = null
			return false
	companion_changed.emit(current_companion)
	return true


func reset_to_default() -> bool:
	if default_companion == null:
		_clear_active_companion()
		current_companion = null
		companion_changed.emit(null)
		return true
	return select_companion(default_companion)


func is_companion(companion_id: StringName) -> bool:
	return (
		current_companion != null
		and current_companion.id == companion_id
	)


func _spawn_companion(companion: CompanionData) -> bool:
	var player := get_parent() as Node2D
	if player == null:
		return false
	var world := player.get_parent()
	var projectile_container := player.get(
		"projectile_container"
	) as Node2D
	var gene_manager := player.get_node_or_null(
		"GeneManager"
	) as GeneManager
	if world == null or projectile_container == null:
		return false

	var spawned := (
		companion.companion_scene.instantiate()
		as CompanionController
	)
	if spawned == null:
		return false
	spawned.configure(
		companion,
		player,
		projectile_container,
		gene_manager
	)
	world.add_child(spawned)
	spawned.global_position = player.global_position + companion.follow_offset
	active_companion = spawned
	return true


func _clear_active_companion() -> void:
	if active_companion == null or not is_instance_valid(active_companion):
		active_companion = null
		return
	active_companion.queue_free()
	active_companion = null
