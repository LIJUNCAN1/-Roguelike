class_name ImpactEffectStatGeneEffect
extends GeneEffect

@export var target_script: Script
@export var float_multipliers: Dictionary = {}
@export var float_additions: Dictionary = {}
@export var property_overrides: Dictionary = {}
@export var attack_tag: StringName


func apply(attack_context: AttackContext) -> void:
	if attack_context == null or target_script == null:
		return

	var modified_any := false
	for impact_effect in attack_context.impact_effects:
		if (
			impact_effect == null
			or impact_effect.get_script() != target_script
		):
			continue

		for property_name in float_multipliers:
			if not _has_property(impact_effect, property_name):
				continue
			var current_value := float(impact_effect.get(property_name))
			impact_effect.set(
				property_name,
				current_value * float(float_multipliers[property_name])
			)
			modified_any = true

		for property_name in float_additions:
			if not _has_property(impact_effect, property_name):
				continue
			var current_value := float(impact_effect.get(property_name))
			impact_effect.set(
				property_name,
				current_value + float(float_additions[property_name])
			)
			modified_any = true

		for property_name in property_overrides:
			if not _has_property(impact_effect, property_name):
				continue
			impact_effect.set(
				property_name,
				property_overrides[property_name]
			)
			modified_any = true

	if modified_any:
		attack_context.add_tag(attack_tag)


func _has_property(object: Object, property_name: Variant) -> bool:
	var expected_name := StringName(property_name)
	for property in object.get_property_list():
		if property.name == expected_name:
			return true
	return false
