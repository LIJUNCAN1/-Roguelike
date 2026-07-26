class_name RangedEnemyController
extends EnemyController

signal projectile_fired(projectile: HostileProjectile)

var ranged_enemy_data: RangedEnemyData
var ranged_cooldown_remaining: float = 0.0


func _ready() -> void:
	super._ready()
	ranged_enemy_data = enemy_data as RangedEnemyData
	if (
		ranged_enemy_data == null
		or ranged_enemy_data.projectile_attack == null
	):
		push_error("Ranged enemy requires projectile attack data.")
		set_physics_process(false)
		return
	ranged_cooldown_remaining = (
		ranged_enemy_data.projectile_attack.initial_delay
	)


func _physics_process(delta: float) -> void:
	if (
		ranged_enemy_data == null
		or target == null
		or not is_instance_valid(target)
	):
		movement_component.move(self, Vector2.ZERO)
		return

	ranged_cooldown_remaining = maxf(
		ranged_cooldown_remaining - delta,
		0.0
	)
	var attack := ranged_enemy_data.projectile_attack
	var target_offset := target.global_position - global_position
	var target_distance := target_offset.length()
	if target_offset.is_zero_approx():
		movement_component.move(self, Vector2.ZERO)
		return

	facing_direction = target_offset.normalized()
	_update_facing_visual()
	if target_distance > attack.preferred_distance:
		movement_component.move(self, facing_direction)
	elif target_distance < attack.retreat_distance:
		movement_component.move(self, -facing_direction)
	else:
		movement_component.move(self, Vector2.ZERO)

	if (
		target_distance <= attack.attack_range
		and ranged_cooldown_remaining <= 0.0
	):
		_fire_projectile()


func _fire_projectile() -> void:
	var attack := ranged_enemy_data.projectile_attack
	if (
		projectile_container == null
		or attack.projectile_scene == null
		or attack.projectile_data == null
	):
		return

	var projectile := (
		attack.projectile_scene.instantiate() as HostileProjectile
	)
	if projectile == null:
		return
	projectile.setup(
		facing_direction,
		attack.projectile_data,
		self
	)
	projectile_container.add_child(projectile)
	projectile.global_position = (
		global_position + facing_direction * attack.muzzle_distance
	)
	ranged_cooldown_remaining = attack.cooldown
	_play_attack_pulse()
	projectile_fired.emit(projectile)
