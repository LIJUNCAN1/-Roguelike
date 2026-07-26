extends Node

@export var fire_gene: GeneData
@export var split_gene: GeneData
@export_node_path("Node") var gene_manager_path: NodePath
@export_node_path("Label") var status_label_path: NodePath

@onready var gene_manager: GeneManager = get_node(
	gene_manager_path
) as GeneManager
@onready var status_label: Label = get_node(status_label_path) as Label


func _ready() -> void:
	gene_manager.genes_changed.connect(_update_status)
	_update_status()


func _unhandled_input(event: InputEvent) -> void:
	var selected_gene: GeneData
	if event.is_action_pressed("toggle_test_gene"):
		selected_gene = fire_gene
	elif event.is_action_pressed("toggle_split_gene"):
		selected_gene = split_gene
	else:
		return

	if gene_manager.has_gene(selected_gene.id):
		gene_manager.remove_gene(selected_gene.id)
	else:
		gene_manager.add_gene(selected_gene)

	get_viewport().set_input_as_handled()


func _update_status() -> void:
	var active_genes := gene_manager.get_active_genes()
	if active_genes.is_empty():
		status_label.text = "基因：无（G 火焰 / H 分裂）"
		status_label.modulate = Color(0.65, 0.72, 0.74, 1.0)
		return

	var gene_names := PackedStringArray()
	for gene in active_genes:
		gene_names.append(gene.display_name)

	status_label.text = "基因：%s（G 火焰 / H 分裂）" % [
		" + ".join(gene_names)
	]
	status_label.modulate = Color(1.0, 0.68, 0.3, 1.0)
