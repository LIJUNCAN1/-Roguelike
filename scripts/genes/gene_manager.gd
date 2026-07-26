class_name GeneManager
extends Node

signal genes_changed

@export var starting_genes: Array[GeneData] = []

var active_genes: Array[GeneData] = []


func _ready() -> void:
	for gene in starting_genes:
		add_gene(gene)


func add_gene(gene: GeneData) -> bool:
	if gene == null or gene.id.is_empty() or has_gene(gene.id):
		return false

	active_genes.append(gene)
	genes_changed.emit()
	return true


func remove_gene(gene_id: StringName) -> bool:
	for index in active_genes.size():
		if active_genes[index].id == gene_id:
			active_genes.remove_at(index)
			genes_changed.emit()
			return true
	return false


func has_gene(gene_id: StringName) -> bool:
	for gene in active_genes:
		if gene.id == gene_id:
			return true
	return false


func get_active_genes() -> Array[GeneData]:
	var genes_copy: Array[GeneData] = []
	genes_copy.assign(active_genes)
	return genes_copy


func modify_attack(attack_context: AttackContext) -> void:
	for gene in active_genes:
		for effect in gene.effects:
			if effect != null:
				effect.apply(attack_context)
