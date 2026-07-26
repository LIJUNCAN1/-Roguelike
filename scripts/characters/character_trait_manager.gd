class_name CharacterTraitManager
extends Node

signal trait_changed(trait_data: CharacterTraitData)
signal energy_changed(current_energy: float, max_energy: float)

@export_node_path("Node") var fusion_manager_path: NodePath

@onready var fusion_manager: FusionManager = get_node(
	fusion_manager_path
) as FusionManager

var active_trait: CharacterTraitData
var current_energy: float = 0.0


func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	if active_trait == null or active_trait.max_energy <= 0.0:
		return
	var previous_energy := current_energy
	current_energy = minf(
		current_energy + active_trait.energy_regeneration * delta,
		active_trait.max_energy
	)
	if not is_equal_approx(previous_energy, current_energy):
		energy_changed.emit(current_energy, active_trait.max_energy)


func configure(trait_data: CharacterTraitData) -> void:
	active_trait = trait_data
	current_energy = (
		trait_data.max_energy if trait_data != null else 0.0
	)
	set_process(
		trait_data != null and trait_data.max_energy > 0.0
	)
	trait_changed.emit(active_trait)
	energy_changed.emit(current_energy, get_max_energy())


func modify_attack(attack_context: AttackContext) -> void:
	if active_trait == null or attack_context == null:
		return
	if (
		active_trait.fusion_damage_multiplier > 1.0
		and not fusion_manager.get_active_fusions().is_empty()
	):
		attack_context.projectile_data.damage *= (
			active_trait.fusion_damage_multiplier
		)
		attack_context.add_tag(&"original_fusion_mastery")

	var is_abyss_attack := (
		attack_context.has_tag(&"lifesteal")
		or attack_context.has_tag(&"venom")
		or attack_context.has_tag(&"frost")
	)
	if is_abyss_attack:
		attack_context.projectile_data.damage *= (
			active_trait.abyss_damage_multiplier
		)
		attack_context.add_tag(&"abyss_affinity")
	for effect in attack_context.impact_effects:
		if effect is LifestealImpactEffect:
			(effect as LifestealImpactEffect).heal_ratio *= (
				active_trait.lifesteal_multiplier
			)
		elif effect is SlowImpactEffect:
			(effect as SlowImpactEffect).duration *= (
				active_trait.control_duration_multiplier
			)

	if (
		active_trait.max_energy > 0.0
		and active_trait.powered_attack_cost > 0.0
		and current_energy >= active_trait.powered_attack_cost
	):
		current_energy -= active_trait.powered_attack_cost
		attack_context.projectile_data.damage *= (
			active_trait.powered_attack_damage_multiplier
		)
		attack_context.add_tag(&"powered_module")
		energy_changed.emit(current_energy, active_trait.max_energy)


func get_max_energy() -> float:
	return active_trait.max_energy if active_trait != null else 0.0


func restore_energy(amount: float) -> void:
	if active_trait == null or active_trait.max_energy <= 0.0:
		return
	current_energy = clampf(
		current_energy + maxf(amount, 0.0),
		0.0,
		active_trait.max_energy
	)
	energy_changed.emit(current_energy, active_trait.max_energy)
