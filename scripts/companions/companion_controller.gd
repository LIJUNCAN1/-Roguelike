class_name CompanionController
extends Node2D

@onready var weapon_component: WeaponComponent = $WeaponComponent
@onready var gene_link_modifier: CompanionGeneLinkModifier = (
	$GeneLinkModifier
)
@onready var facing_marker: Polygon2D = $Visuals/FacingMarker

var companion_data: CompanionData
var player: Node2D
var projectile_container: Node2D
var gene_manager: GeneManager
var current_target: Node2D
var facing_direction: Vector2 = Vector2.RIGHT


func configure(
	data: CompanionData,
	owner_player: Node2D,
	projectiles: Node2D,
	player_gene_manager: GeneManager
) -> void:
	companion_data = data
	player = owner_player
	projectile_container = projectiles
	gene_manager = player_gene_manager


func _ready() -> void:
	if (
		companion_data == null
		or companion_data.weapon_data == null
		or player == null
		or projectile_container == null
	):
		push_error("Companion requires valid data, player and projectiles.")
		set_physics_process(false)
		return

	weapon_component.set_weapon_data(companion_data.weapon_data)
	gene_link_modifier.configure(companion_data, gene_manager)


func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return

	var desired_position := (
		player.global_position + companion_data.follow_offset
	)
	global_position = global_position.move_toward(
		desired_position,
		companion_data.move_speed * delta
	)

	current_target = _find_nearest_enemy()
	if current_target == null:
		return

	var target_offset := current_target.global_position - global_position
	if target_offset.is_zero_approx():
		return
	facing_direction = target_offset.normalized()
	facing_marker.rotation = facing_direction.angle()
	weapon_component.try_fire(
		projectile_container,
		global_position + facing_direction * 10.0,
		facing_direction
	)


func _find_nearest_enemy() -> Node2D:
	var nearest: Node2D
	var nearest_distance_squared := (
		companion_data.target_range * companion_data.target_range
	)
	for node in get_tree().get_nodes_in_group(&"room_enemies"):
		var enemy := node as Node2D
		if enemy == null or enemy.is_queued_for_deletion():
			continue
		var distance_squared := global_position.distance_squared_to(
			enemy.global_position
		)
		if distance_squared > nearest_distance_squared:
			continue
		nearest = enemy
		nearest_distance_squared = distance_squared
	return nearest


func get_reward_owner() -> Node:
	return player
