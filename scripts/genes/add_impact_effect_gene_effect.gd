class_name AddImpactEffectGeneEffect
extends GeneEffect

@export var impact_effect: ProjectileImpactEffect
@export var attack_tag: StringName


func apply(attack_context: AttackContext) -> void:
	if attack_context == null or impact_effect == null:
		return

	attack_context.add_impact_effect(impact_effect)
	attack_context.add_tag(attack_tag)
