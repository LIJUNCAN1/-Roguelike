class_name ProjectileStatGeneEffect
extends GeneEffect

@export var attack_tag: StringName

@export_group("Damage")
@export_range(0.0, 100.0, 0.05, "or_greater")
var damage_multiplier: float = 1.0
@export_range(-100000.0, 100000.0, 1.0)
var flat_damage: float = 0.0

@export_group("Projectile")
@export_range(0.0, 100.0, 0.05, "or_greater")
var speed_multiplier: float = 1.0
@export_range(0.1, 20.0, 0.05, "or_greater")
var radius_multiplier: float = 1.0
@export_range(0, 100, 1, "or_greater")
var additional_hits: int = 0
@export var override_color: bool = false
@export var projectile_color: Color = Color.WHITE


func apply(attack_context: AttackContext) -> void:
	if attack_context == null or attack_context.projectile_data == null:
		return

	var projectile_data := attack_context.projectile_data
	projectile_data.damage = maxf(
		projectile_data.damage * damage_multiplier + flat_damage,
		0.0
	)
	projectile_data.speed *= speed_multiplier
	projectile_data.radius *= radius_multiplier
	projectile_data.max_hits += additional_hits

	if override_color:
		projectile_data.color = projectile_color

	attack_context.add_tag(attack_tag)
