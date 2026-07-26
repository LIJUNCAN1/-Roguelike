class_name EvolutionData
extends Resource

@export_group("Identity")
@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var priority: int = 0

@export_group("Requirements")
@export var required_gene_ids: Array[StringName] = []
@export var required_fusion_ids: Array[StringName] = []

@export_group("Presentation")
@export var visual_scene: PackedScene
@export var pixel_visual_data: ActorVisualData

@export_group("Combat")
@export var effects: Array[GeneEffect] = []


func requirements_met(
	gene_manager: GeneManager,
	fusion_manager: FusionManager
) -> bool:
	for gene_id in required_gene_ids:
		if not gene_manager.has_gene(gene_id):
			return false

	for fusion_id in required_fusion_ids:
		if not fusion_manager.has_fusion(fusion_id):
			return false

	return true
