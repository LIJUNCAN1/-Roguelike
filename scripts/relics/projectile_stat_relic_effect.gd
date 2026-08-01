class_name ProjectileStatRelicEffect
extends RelicEffect

@export_range(0.0, 100.0, 0.01, "or_greater")
var damage_multiplier: float = 1.0
@export_range(0.1, 20.0, 0.01, "or_greater")
var radius_multiplier: float = 1.0
@export_range(0.0, 100.0, 0.01, "or_greater")
var speed_multiplier: float = 1.0
@export_range(0, 20, 1, "or_greater")
var bonus_hits: int = 0
@export_range(0.0, 1.0, 0.01)
var critical_chance_bonus: float = 0.0
@export var effect_tag: StringName = &"item"


func apply(attack_context: AttackContext) -> void:
	if attack_context == null or attack_context.projectile_data == null:
		return
	attack_context.projectile_data.damage *= damage_multiplier
	attack_context.projectile_data.radius *= radius_multiplier
	attack_context.projectile_data.speed *= speed_multiplier
	attack_context.projectile_data.max_hits += bonus_hits
	attack_context.projectile_data.critical_chance = clampf(
		attack_context.projectile_data.critical_chance
		+ critical_chance_bonus,
		0.0,
		1.0
	)
	attack_context.add_tag(effect_tag)
