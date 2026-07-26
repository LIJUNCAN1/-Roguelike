class_name FusionData
extends Resource

@export_group("Identity")
@export var id: StringName
@export var display_name: String
@export_multiline var description: String

@export_group("Requirements")
@export var required_gene_ids: Array[StringName] = []

@export_group("Effects")
@export var effects: Array[GeneEffect] = []


func requirements_met(gene_manager: GeneManager) -> bool:
	if gene_manager == null or required_gene_ids.is_empty():
		return false

	for gene_id in required_gene_ids:
		if not gene_manager.has_gene(gene_id):
			return false
	return true
