class_name WeaponComponent
extends Node

@export var weapon_data: WeaponData

var cooldown_remaining: float = 0.0


func _physics_process(delta: float) -> void:
	cooldown_remaining = maxf(cooldown_remaining - delta, 0.0)


func try_fire(
	projectile_parent: Node,
	spawn_position: Vector2,
	direction: Vector2
) -> Node2D:
	if weapon_data == null or weapon_data.projectile_scene == null:
		push_error("WeaponComponent requires valid WeaponData.")
		return null

	if projectile_parent == null or direction.is_zero_approx():
		return null

	if cooldown_remaining > 0.0:
		return null

	var projectile := weapon_data.projectile_scene.instantiate() as Node2D
	projectile.call("setup", direction)
	projectile_parent.add_child(projectile)
	projectile.global_position = spawn_position
	cooldown_remaining = weapon_data.fire_cooldown
	return projectile
