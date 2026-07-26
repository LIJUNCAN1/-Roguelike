class_name ExplosionUpgradeFusionEffect
extends GeneEffect

@export_range(1.0, 10.0, 0.05, "or_greater")
var damage_multiplier: float = 2.0
@export_range(1.0, 10.0, 0.05, "or_greater")
var radius_multiplier: float = 1.5
@export var effect_color: Color = Color(1.0, 0.15, 0.03, 1.0)
@export var attack_tag: StringName = &"fire_burst_fusion"


func apply(attack_context: AttackContext) -> void:
	if attack_context == null:
		return

	for impact_effect in attack_context.impact_effects:
		var explosion := impact_effect as ExplosionImpactEffect
		if explosion == null:
			continue

		explosion.damage *= damage_multiplier
		explosion.radius *= radius_multiplier
		explosion.effect_color = effect_color

	attack_context.add_tag(attack_tag)
