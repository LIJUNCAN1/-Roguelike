class_name TaggedProjectileStatRelicEffect
extends RelicEffect

@export var required_tag: StringName
@export_range(0.0, 100.0, 0.05, "or_greater")
var damage_multiplier: float = 1.0
@export_range(0.1, 20.0, 0.05, "or_greater")
var radius_multiplier: float = 1.0
@export_range(0.0, 100.0, 0.05, "or_greater")
var speed_multiplier: float = 1.0


func apply(attack_context: AttackContext) -> void:
	if (
		attack_context == null
		or attack_context.projectile_data == null
		or not attack_context.has_tag(required_tag)
	):
		return

	attack_context.projectile_data.damage *= damage_multiplier
	attack_context.projectile_data.radius *= radius_multiplier
	attack_context.projectile_data.speed *= speed_multiplier
