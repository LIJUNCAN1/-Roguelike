class_name WeaponComponent
extends Node

@export var weapon_data: WeaponData
@export_node_path("Node") var attack_modifier_path: NodePath

@onready var attack_modifier: Node = get_node_or_null(
	attack_modifier_path
)

var cooldown_remaining: float = 0.0


func _physics_process(delta: float) -> void:
	cooldown_remaining = maxf(cooldown_remaining - delta, 0.0)


func try_fire(
	projectile_parent: Node,
	spawn_position: Vector2,
	direction: Vector2
) -> Node2D:
	if (
		weapon_data == null
		or weapon_data.projectile_scene == null
		or weapon_data.projectile_data == null
	):
		push_error("WeaponComponent requires valid WeaponData.")
		return null

	if projectile_parent == null or direction.is_zero_approx():
		return null

	if cooldown_remaining > 0.0:
		return null

	var attack_context := AttackContext.new(
		weapon_data.projectile_scene,
		weapon_data.projectile_data,
		direction
	)
	if (
		attack_modifier != null
		and attack_modifier.has_method("modify_attack")
	):
		attack_modifier.call("modify_attack", attack_context)

	var first_projectile: Node2D
	for projectile_direction in attack_context.directions:
		var projectile := (
			attack_context.projectile_scene.instantiate() as Node2D
		)
		projectile.call(
			"setup",
			projectile_direction,
			attack_context.projectile_data,
			attack_context.tags
		)
		projectile_parent.add_child(projectile)
		projectile.global_position = spawn_position
		if first_projectile == null:
			first_projectile = projectile

	if first_projectile == null:
		return null

	cooldown_remaining = weapon_data.fire_cooldown
	return first_projectile
