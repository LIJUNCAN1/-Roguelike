class_name GrantRandomGeneEventEffect
extends EventEffect

@export var gene_pool: GeneRewardPoolData
@export_range(1, 3, 1) var amount: int = 1


func apply(context: EventContext) -> void:
	if (
		context == null
		or context.gene_manager == null
		or context.rng == null
		or gene_pool == null
	):
		return

	for _gene_index in amount:
		var available := gene_pool.get_available_genes(
			context.gene_manager
		)
		if available.is_empty():
			return
		var selected_index := context.rng.randi_range(
			0,
			available.size() - 1
		)
		context.gene_manager.add_gene(available[selected_index])
