class_name CompanionGeneLinkModifier
extends Node

var companion_data: CompanionData
var gene_manager: GeneManager


func configure(
	data: CompanionData,
	player_gene_manager: GeneManager
) -> void:
	companion_data = data
	gene_manager = player_gene_manager


func modify_attack(attack_context: AttackContext) -> void:
	if (
		attack_context == null
		or attack_context.projectile_data == null
		or companion_data == null
		or gene_manager == null
		or companion_data.linked_gene_id.is_empty()
		or not gene_manager.has_gene(companion_data.linked_gene_id)
	):
		return

	attack_context.projectile_data.damage *= (
		companion_data.linked_gene_damage_multiplier
	)
	attack_context.tags.append(&"companion_gene_link")
