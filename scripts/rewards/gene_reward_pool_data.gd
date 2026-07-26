class_name GeneRewardPoolData
extends Resource

@export_range(1, 5, 1) var choice_count: int = 3
@export var genes: Array[GeneData] = []


func get_available_genes(gene_manager: GeneManager) -> Array[GeneData]:
	var available: Array[GeneData] = []
	if gene_manager == null:
		return available

	for gene in genes:
		if (
			gene != null
			and not gene.id.is_empty()
			and not gene_manager.has_gene(gene.id)
		):
			available.append(gene)
	return available
